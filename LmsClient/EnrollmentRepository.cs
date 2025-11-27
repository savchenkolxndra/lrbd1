using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Npgsql;

namespace LmsClient
{
    public class EnrollmentRepository : IEnrollmentRepository
    {
        private readonly NpgsqlConnection _conn;
        private readonly NpgsqlTransaction _tx;

        public EnrollmentRepository(NpgsqlConnection conn, NpgsqlTransaction tx)
        {
            _conn = conn;
            _tx = tx;
        }

        // Читання тільки через view v_enrollments_detailed
        public async Task<IEnumerable<EnrollmentDto>> GetEnrollmentsAsync(CancellationToken ct = default)
        {
            const string sql = @"
                SELECT enrollment_id, course_id, course_title,
                       student_id, student_name, status, enrolled_at
                FROM v_enrollments_detailed";

            using var cmd = new NpgsqlCommand(sql, _conn, _tx);
            using var reader = await cmd.ExecuteReaderAsync(ct);

            var list = new List<EnrollmentDto>();

            while (await reader.ReadAsync(ct))
            {
                list.Add(new EnrollmentDto
                {
                    EnrollmentId = reader.GetInt32(0),
                    CourseId = reader.GetInt32(1),
                    CourseTitle = reader.GetString(2),
                    StudentId = reader.GetInt32(3),
                    StudentName = reader.GetString(4),
                    Status = reader.GetString(5),
                    EnrolledAt = reader.GetDateTime(6)
                });
            }

            return list;
        }

        // Записати студента на курс через fn_enroll_student(...)
        public async Task<int> EnrollStudentAsync(int courseId, int studentId, int actorId, CancellationToken ct = default)
        {
            const string sql = "SELECT fn_enroll_student(@course_id, @student_id, @actor_id);";

            using var cmd = new NpgsqlCommand(sql, _conn, _tx);
            cmd.Parameters.AddWithValue("course_id", courseId);
            cmd.Parameters.AddWithValue("student_id", studentId);
            cmd.Parameters.AddWithValue("actor_id", actorId);

            var result = await cmd.ExecuteScalarAsync(ct);
            return Convert.ToInt32(result);
        }

        // Відрахувати студента з курсу
        public async Task UnenrollStudentAsync(int courseId, int studentId, int actorId, CancellationToken ct = default)
        {
            const string sql = "SELECT fn_unenroll_student(@course_id, @student_id, @actor_id);";

            using var cmd = new NpgsqlCommand(sql, _conn, _tx);
            cmd.Parameters.AddWithValue("course_id", courseId);
            cmd.Parameters.AddWithValue("student_id", studentId);
            cmd.Parameters.AddWithValue("actor_id", actorId);

            await cmd.ExecuteNonQueryAsync(ct);
        }
    }
}

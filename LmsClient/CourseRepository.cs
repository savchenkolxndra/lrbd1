using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using Npgsql;

namespace LmsClient
{
    public class CourseRepository : ICourseRepository
    {
        private readonly NpgsqlConnection _conn;
        private readonly NpgsqlTransaction _tx;

        public CourseRepository(NpgsqlConnection conn, NpgsqlTransaction tx)
        {
            _conn = conn;
            _tx = tx;
        }

        // Читання тільки через view v_courses_active
        public async Task<IEnumerable<CourseDto>> GetActiveCoursesAsync(CancellationToken ct = default)
        {
            const string sql = @"
                SELECT id, category_id, title, description, level, start_date, end_date
                FROM v_courses_active";

            using var cmd = new NpgsqlCommand(sql, _conn, _tx);
            using var reader = await cmd.ExecuteReaderAsync(ct);

            var list = new List<CourseDto>();

            while (await reader.ReadAsync(ct))
            {
                list.Add(new CourseDto
                {
                    Id = reader.GetInt32(0),
                    CategoryId = reader.IsDBNull(1) ? null : reader.GetInt32(1),
                    Title = reader.GetString(2),
                    Description = reader.IsDBNull(3) ? null : reader.GetString(3),
                    Level = reader.IsDBNull(4) ? null : reader.GetString(4),
                    StartDate = reader.IsDBNull(5) ? null : reader.GetDateTime(5),
                    EndDate = reader.IsDBNull(6) ? null : reader.GetDateTime(6)
                });
            }

            return list;
        }

        // Створення курсу через fn_create_course(...)
        public async Task<int> CreateCourseAsync(string title, string? description, int? categoryId, int creatorId, CancellationToken ct = default)
        {
            const string sql = "SELECT fn_create_course(@title, @description, @category_id, @creator_id);";

            using var cmd = new NpgsqlCommand(sql, _conn, _tx);
            cmd.Parameters.AddWithValue("title", title);
            cmd.Parameters.AddWithValue("description", (object?)description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("category_id", (object?)categoryId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("creator_id", creatorId);

            var result = await cmd.ExecuteScalarAsync(ct);
            return Convert.ToInt32(result);
        }

        // Soft delete курсу через fn_soft_delete_course(...)
        public async Task SoftDeleteCourseAsync(int courseId, int actorId, CancellationToken ct = default)
        {
            const string sql = "SELECT fn_soft_delete_course(@course_id, @actor_id);";

            using var cmd = new NpgsqlCommand(sql, _conn, _tx);
            cmd.Parameters.AddWithValue("course_id", courseId);
            cmd.Parameters.AddWithValue("actor_id", actorId);

            await cmd.ExecuteNonQueryAsync(ct);
        }
    }
}

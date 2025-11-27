using System;
using System.Threading.Tasks;

namespace LmsClient
{
    internal class Program
    {
        private const string ConnectionString =
            "Host=localhost;Port=5432;Database=courses;Username=postgres;Password=password";

        static async Task Main(string[] args)
        {
            Console.WriteLine("LMS demo started...");

            await using var uow = new PgUnitOfWork(ConnectionString);

            // 1. Показати всі активні курси (з v_courses_active)
            Console.WriteLine("\nActive courses:");
            var courses = await uow.Courses.GetActiveCoursesAsync();

            foreach (var c in courses)
            {
                Console.WriteLine($"[{c.Id}] {c.Title} ({c.Level})");
            }

            int courseId = 1; 
            int studentId = 4;
            int actorId = 1;

            Console.WriteLine($"\nEnrolling student {studentId} to course {courseId}...");

            int enrollmentId = await uow.Enrollments.EnrollStudentAsync(courseId, studentId, actorId);
            Console.WriteLine($"Enrollment id: {enrollmentId}");

            // 3. Показати детальні записи (v_enrollments_detailed)
            Console.WriteLine("\nEnrollments:");
            var enrollments = await uow.Enrollments.GetEnrollmentsAsync();

            foreach (var e in enrollments)
            {
                Console.WriteLine($"[{e.EnrollmentId}] {e.StudentName} → {e.CourseTitle} ({e.Status})");
            }

            // 4. Фіксуємо транзакцію
            await uow.CommitAsync();

            Console.WriteLine("\nDone. Press any key to exit.");
            Console.ReadKey();
        }
    }
}

using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace LmsClient
{
    public interface ICourseRepository
    {
        Task<IEnumerable<CourseDto>> GetActiveCoursesAsync(CancellationToken ct = default);
        Task<int> CreateCourseAsync(string title, string? description, int? categoryId, int creatorId, CancellationToken ct = default);
        Task SoftDeleteCourseAsync(int courseId, int actorId, CancellationToken ct = default);
    }

    public interface IEnrollmentRepository
    {
        Task<IEnumerable<EnrollmentDto>> GetEnrollmentsAsync(CancellationToken ct = default);
        Task<int> EnrollStudentAsync(int courseId, int studentId, int actorId, CancellationToken ct = default);
        Task UnenrollStudentAsync(int courseId, int studentId, int actorId, CancellationToken ct = default);
    }

    public interface IUnitOfWork : IAsyncDisposable
    {
        ICourseRepository Courses { get; }
        IEnrollmentRepository Enrollments { get; }

        Task CommitAsync(CancellationToken ct = default);
    }
}

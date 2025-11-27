using System.Threading;
using System.Threading.Tasks;
using Npgsql;

namespace LmsClient
{
    public class PgUnitOfWork : IUnitOfWork
    {
        private readonly NpgsqlConnection _connection;
        private readonly NpgsqlTransaction _transaction;

        public ICourseRepository Courses { get; }
        public IEnrollmentRepository Enrollments { get; }

        public PgUnitOfWork(string connectionString)
        {
            _connection = new NpgsqlConnection(connectionString);
            _connection.Open();
            _transaction = _connection.BeginTransaction();

            Courses = new CourseRepository(_connection, _transaction);
            Enrollments = new EnrollmentRepository(_connection, _transaction);
        }

        public async Task CommitAsync(CancellationToken ct = default)
        {
            await _transaction.CommitAsync(ct);
        }

        public async ValueTask DisposeAsync()
        {
            await _transaction.DisposeAsync();
            await _connection.DisposeAsync();
        }
    }
}

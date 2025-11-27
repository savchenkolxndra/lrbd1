using System;

namespace LmsClient
{
    public class CourseDto
    {
        public int Id { get; set; }
        public int? CategoryId { get; set; }
        public string Title { get; set; } = default!;
        public string? Description { get; set; }
        public string? Level { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
    }

    public class EnrollmentDto
    {
        public int EnrollmentId { get; set; }
        public int CourseId { get; set; }
        public string CourseTitle { get; set; } = default!;
        public int StudentId { get; set; }
        public string StudentName { get; set; } = default!;
        public string Status { get; set; } = default!;
        public DateTime EnrolledAt { get; set; }
    }
}

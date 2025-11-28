-- B-Tree індекс (композитний) — enrollment
CREATE UNIQUE INDEX idx_enrollment_student_course 
    ON enrollment(student_id, course_id);
-- GIN індекс для повнотекстового пошуку
CREATE INDEX idx_course_search 
    ON course USING GIN(search_vector);

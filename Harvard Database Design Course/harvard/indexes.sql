
CREATE INDEX enrollments_student ON enrollments (student_id);

CREATE INDEX courses_semester ON COURSES (semester);

CREATE INDEX enrollments_course ON ENROLLMENTS (course_id);

CREATE INDEX courses_department_semester ON COURSES (semester,department);

CREATE INDEX satisfies_courses ON SATISFIES (course_id, requirement_id);

CREATE INDEX requirements_id ON REQUIREMENTS (id);

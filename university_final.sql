USE university;

#The average grade that is given by each professor
SELECT 
	p.professors_name AS "Professor's name", 
    AVG(g.grades_grade) AS "Average grade", 
    c.courses_name AS "Course name"
FROM professors p 
JOIN courses c
ON c.courses_professors_id = p.professors_id
JOIN enrollment e
ON c.courses_id = enrollment_courses_id
JOIN grades g
ON e.enrollment_id = g.grades_enrollment_id
GROUP BY p.professors_name, c.courses_name;

# The top grades for each student
SELECT
	s.students_name AS 'Name',
    MAX(g.grades_grade) AS 'Top grade'
FROM enrollment e
JOIN students s
ON enrollment_students_id = students_id
JOIN grades g
ON enrollment_id = grades_enrollment_id
GROUP BY s.students_name;


#Sort students by the courses that they are enrolled in
SELECT 
	s.students_name AS "Student's name",
    c.courses_name AS 'Course'
    FROM enrollment e
		LEFT JOIN (
        SELECT students_id, students_name
        FROM students ) AS s
        ON s.students_id = e.enrollment_students_id
        LEFT JOIN (
        SELECT courses_name, courses_id
        FROM courses ) AS c
        ON c.courses_id = e.enrollment_courses_id
	ORDER BY s.students_name;
         
         
#Create a summary report of courses and their average grades, sorted by the most challenging course (course with the lowest average grade) to the easiest course
SELECT 
	c.courses_name AS 'Course',
    AVG(g.grades_grade) AS 'Average grade'
    #AVG(CAST(g.grades_grade as UNSIGNED)) AS 'Average grade'
FROM enrollment e
JOIN courses c
ON c.courses_id = enrollment_courses_id
JOIN grades g
ON e.enrollment_id = g.grades_enrollment_id
GROUP BY c.courses_name
ORDER BY `Average grade` ASC;

# Finding which student and professor have the most courses in common
SELECT enrollment_students_id, COUNT(*) AS num_courses
FROM enrollment e
JOIN courses c ON e.enrollment_courses_id = c.courses_id
GROUP BY enrollment_students_id;

SELECT courses_professors_id, COUNT(*) AS num_courses
FROM courses c 
JOIN professors p ON c.courses_professors_id = p.professors_id
GROUP BY courses_professors_id;


SELECT
	s.students_name AS "Student's name",
    p.professors_name AS "Professor's name",
    MAX(num_courses_in_common) AS "Max courses in common"
FROM (
	SELECT e.enrollment_students_id, c.courses_professors_id, COUNT(*) AS num_courses_in_common
	FROM enrollment e
	JOIN students s ON s.students_id = e.enrollment_students_id
	JOIN courses c ON c.courses_id = e.enrollment_courses_id
	JOIN professors p ON p.professors_id = c.courses_professors_id
	GROUP BY e.enrollment_students_id, c.courses_professors_id
) AS `Common courses`
JOIN students s ON s.students_id = `Common courses`.enrollment_students_id
JOIN professors p ON p.professors_id = `Common courses`.courses_professors_id
WHERE num_courses_in_common = (
	SELECT MAX(num_courses_in_common)
    FROM (
		SELECT e.enrollment_students_id, c.courses_professors_id, COUNT(*) AS num_courses_in_common
	FROM enrollment e
	JOIN students s ON s.students_id = e.enrollment_students_id
	JOIN courses c ON c.courses_id = e.enrollment_courses_id
	JOIN professors p ON p.professors_id = c.courses_professors_id
	GROUP BY e.enrollment_students_id, c.courses_professors_id
    ) AS `Inner common courses`
)
GROUP BY s.students_name, p.professors_name;

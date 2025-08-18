USE student_mental_health; -- Ensure you're in the correct database

DROP TABLE IF EXISTS students; -- Safely drops the table if it exists
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    is_international BOOLEAN,
    enrollment_date DATE -- New: Stores the date the student enrolled
);
CREATE TABLE demographics (
    student_id INT PRIMARY KEY, -- This will also be a Foreign Key
    age INT,
    gender VARCHAR(10), -- e.g., 'Male', 'Female', 'Non-binary'
    country_of_origin VARCHAR(50),
    program_of_study VARCHAR(100),
    CONSTRAINT fk_student_demographics FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE surveys (
    survey_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT, -- This will be a Foreign Key
    survey_date DATE, -- New: Date the survey was taken
    anxiety_score INT,
    depression_score INT,
    social_connectedness_score INT,
    CONSTRAINT fk_student_surveys FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
USE student_mental_health;

-- Inserting student core data
INSERT INTO students (is_international, enrollment_date) VALUES
(TRUE, '2023-01-15'),   -- Student 1: International, enrolled Jan 2023
(TRUE, '2023-07-20'),   -- Student 2: International, enrolled July 2023
(FALSE, '2022-03-10'),  -- Student 3: Domestic, enrolled Mar 2022
(TRUE, '2024-01-01'),   -- Student 4: International, enrolled Jan 2024
(TRUE, '2022-11-05');   -- Student 5: International, enrolled Nov 2022
-- Inserting demographic data
INSERT INTO demographics (student_id, age, gender, country_of_origin, program_of_study) VALUES
(1, 20, 'Female', 'South Korea', 'Computer Science'),
(2, 22, 'Male', 'India', 'Business Administration'),
(3, 19, 'Female', 'Japan', 'Linguistics'),
(4, 21, 'Male', 'Vietnam', 'Engineering'),
(5, 23, 'Female', 'Brazil', 'Fine Arts');
-- Inserting survey data (multiple surveys for some students)
INSERT INTO surveys (student_id, survey_date, anxiety_score, depression_score, social_connectedness_score) VALUES
(1, '2023-04-15', 75, 60, 40), -- S1: 3 months after enrollment
(1, '2023-10-15', 60, 50, 55), -- S1: 9 months after enrollment (improved scores)
(2, '2023-09-20', 80, 70, 35), -- S2: 2 months after enrollment (high initial scores)
(2, '2024-01-20', 65, 60, 50), -- S2: 6 months after enrollment
(3, '2023-06-10', 30, 25, 80), -- S3: Domestic, long stay
(4, '2024-03-01', 90, 85, 20), -- S4: 2 months after enrollment (very high scores - new int'l student)
(5, '2023-02-05', 40, 35, 70), -- S5: 3 months after enrollment
(5, '2023-08-05', 30, 25, 85), -- S5: 9 months after enrollment
(1, '2024-01-15', 50, 40, 65); -- S1: 1 year after enrollment (further improvement)
SELECT * FROM students;
SELECT * FROM demographics;
SELECT * FROM surveys;
USE student_mental_health;

SELECT
    s.student_id,
    d.country_of_origin,
    d.program_of_study,
    s.is_international,
    s.enrollment_date,
    su.survey_date,
    TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date) AS length_of_stay_months,
    su.anxiety_score,
    su.depression_score,
    su.social_connectedness_score
FROM
    students s
INNER JOIN
    demographics d ON s.student_id = d.student_id
INNER JOIN
    surveys su ON s.student_id = su.student_id
WHERE
    s.is_international = TRUE -- Still focusing on international students
ORDER BY
    s.student_id, su.survey_date;
USE student_mental_health;

SELECT
    s.student_id,
    d.country_of_origin,
    su.survey_date,
    TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date) AS length_of_stay_months,
    su.anxiety_score,
    AVG(su.anxiety_score) OVER (PARTITION BY TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date)) AS avg_anxiety_for_stay_group,
    su.depression_score,
    AVG(su.depression_score) OVER (PARTITION BY TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date)) AS avg_depression_for_stay_group,
    su.social_connectedness_score,
    AVG(su.social_connectedness_score) OVER (PARTITION BY TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date)) AS avg_connectedness_for_stay_group
FROM
    students s
INNER JOIN
    demographics d ON s.student_id = d.student_id
INNER JOIN
    surveys su ON s.student_id = su.student_id
WHERE
    s.is_international = TRUE
ORDER BY
    s.student_id, su.survey_date;
USE student_mental_health;

SELECT
    TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date) AS length_of_stay_months,
    AVG(CASE WHEN d.gender = 'Male' THEN su.anxiety_score END) AS avg_anxiety_male,
    AVG(CASE WHEN d.gender = 'Female' THEN su.anxiety_score END) AS avg_anxiety_female,
    COUNT(CASE WHEN d.gender = 'Male' THEN s.student_id END) AS num_male_surveys,
    COUNT(CASE WHEN d.gender = 'Female' THEN s.student_id END) AS num_female_surveys
FROM
    students s
INNER JOIN
    demographics d ON s.student_id = d.student_id
INNER JOIN
    surveys su ON s.student_id = su.student_id
WHERE
    s.is_international = TRUE
GROUP BY
    length_of_stay_months
ORDER BY
    length_of_stay_months;
USE student_mental_health;

WITH InternationalStudentSurveys AS (
    SELECT
        s.student_id,
        d.country_of_origin,
        d.gender,
        TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date) AS length_of_stay_months,
        su.anxiety_score,
        su.depression_score,
        su.social_connectedness_score
    FROM
        students s
    INNER JOIN
        demographics d ON s.student_id = d.student_id
    INNER JOIN
        surveys su ON s.student_id = su.student_id
    WHERE
        s.is_international = TRUE
)
SELECT
    length_of_stay_months,
    AVG(anxiety_score) AS average_anxiety_score,
    AVG(depression_score) AS average_depression_score,
    AVG(social_connectedness_score) AS average_social_connectedness_score,
    AVG(CASE WHEN gender = 'Male' THEN anxiety_score END) AS avg_anxiety_male,
    AVG(CASE WHEN gender = 'Female' THEN anxiety_score END) AS avg_anxiety_female
FROM
    InternationalStudentSurveys
GROUP BY
    length_of_stay_months
ORDER BY
    length_of_stay_months;
USE student_mental_health;
CREATE INDEX idx_is_international ON students (is_international);
CREATE INDEX idx_country_of_origin ON demographics (country_of_origin);
USE student_mental_health;
EXPLAIN SELECT
    s.student_id,
    d.country_of_origin,
    TIMESTAMPDIFF(MONTH, s.enrollment_date, su.survey_date) AS length_of_stay_months
FROM
    students s
INNER JOIN
    demographics d ON s.student_id = d.student_id
INNER JOIN
    surveys su ON s.student_id = su.student_id
WHERE
    s.is_international = TRUE;

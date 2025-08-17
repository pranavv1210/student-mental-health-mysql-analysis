CREATE DATABASE student_mental_health;
USE student_mental_health;
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    is_international BOOLEAN,
    length_of_stay_months INT,
    anxiety_score INT,
    depression_score INT,
    social_connectedness_score INT
);
-- Use the database we created
USE student_mental_health;

-- Inserting sample data into the students table
INSERT INTO students (is_international, length_of_stay_months, anxiety_score, depression_score, social_connectedness_score) VALUES
(TRUE, 6, 75, 60, 40),   -- International, 6 months, higher anxiety
(TRUE, 12, 50, 45, 65),  -- International, 12 months, moderate scores
(FALSE, 24, 30, 25, 80), -- Domestic, longer stay, lower scores
(TRUE, 3, 85, 70, 30),   -- International, very short stay, high scores
(TRUE, 18, 40, 35, 70),  -- International, 18 months, good scores
(FALSE, 12, 20, 15, 90), -- Domestic, 12 months, very low scores
(TRUE, 9, 60, 55, 50),   -- International, 9 months, mid-range scores
(TRUE, 24, 35, 30, 75),  -- International, 24 months, good scores
(FALSE, 6, 45, 40, 55),  -- Domestic, shorter stay, moderate scores
(TRUE, 30, 25, 20, 85);  -- International, very long stay, very good scores
SELECT * FROM students;
USE student_mental_health;

SELECT
    student_id,
    is_international,
    length_of_stay_months,
    anxiety_score,
    depression_score,
    social_connectedness_score
FROM
    students
WHERE
    is_international = TRUE; -- Filters for international students
USE student_mental_health;

SELECT
    length_of_stay_months,
    AVG(anxiety_score) AS average_anxiety_score,
    AVG(depression_score) AS average_depression_score,
    AVG(social_connectedness_score) AS average_social_connectedness_score
FROM
    students
WHERE
    is_international = TRUE -- Filter only international students
GROUP BY
    length_of_stay_months -- Group results by length of stay
ORDER BY
    length_of_stay_months; -- Order for readability

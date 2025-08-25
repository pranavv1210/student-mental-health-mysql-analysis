USE student_mental_health;

-- Drop existing tables (if any) to ensure clean setup for the new data
-- Order matters for dropping: child tables (surveys, demographics) before parent (students)
DROP TABLE IF EXISTS surveys;
DROP TABLE IF EXISTS demographics;
DROP TABLE IF EXISTS students;

-- Create students table (simplified)
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT
);

-- Create demographics table with Foreign Key to students
CREATE TABLE demographics (
    student_id INT PRIMARY KEY, -- FK to students
    age INT,
    gender VARCHAR(10),
    program_of_study VARCHAR(100), -- From 'What is your course?'
    CONSTRAINT fk_student_demographics FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create surveys table with Foreign Key to students and new fields
CREATE TABLE surveys (
    survey_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT, -- FK to students
    survey_date DATETIME, -- From 'Timestamp', now DATETIME
    year_of_study INT, -- From 'Your current year of Study'
    cypa_range VARCHAR(50), -- From 'What is your CGPA?'
    marital_status VARCHAR(20), -- From 'Marital status'
    anxiety_score INT,        -- 'Yes'/'No' converted to 1/0
    depression_score INT,     -- 'Yes'/'No' converted to 1/0
    panic_attack_score INT,   -- 'Yes'/'No' converted to 1/0 (NEW)
    sought_treatment INT,     -- 'Yes'/'No' converted to 1/0 (NEW)
    CONSTRAINT fk_student_surveys FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
USE student_mental_health;

-- Temporarily disable foreign key checks to drop surveys
SET FOREIGN_KEY_CHECKS = 0;

-- Drop the surveys table
DROP TABLE IF EXISTS surveys;

-- Recreate the surveys table with the corrected 'cgpa_range' column name
CREATE TABLE surveys (
    survey_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT, -- FK to students
    survey_date DATETIME, -- From 'Timestamp', now DATETIME
    year_of_study INT, -- From 'Your current year of Study'
    cgpa_range VARCHAR(50), -- CORRECTED: This was 'cypa_range' before
    marital_status VARCHAR(20), -- From 'Marital status'
    anxiety_score INT,        -- 'Yes'/'No' converted to 1/0
    depression_score INT,     -- 'Yes'/'No' converted to 1/0
    panic_attack_score INT,   -- 'Yes'/'No' converted to 1/0 (NEW)
    sought_treatment INT,     -- 'Yes'/'No' converted to 1/0 (NEW)
    CONSTRAINT fk_student_surveys FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
USE student_mental_health;

-- Temporarily disable foreign key checks to allow dropping tables
SET FOREIGN_KEY_CHECKS = 0;

-- Drop all three tables to ensure a completely clean slate
-- Order matters: child tables first, then parent
DROP TABLE IF EXISTS surveys;
DROP TABLE IF EXISTS demographics;
DROP TABLE IF EXISTS students;

-- Recreate students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT
);

-- Recreate demographics table
CREATE TABLE demographics (
    student_id INT PRIMARY KEY, -- FK to students
    age INT,
    gender VARCHAR(10),
    program_of_study VARCHAR(100),
    CONSTRAINT fk_student_demographics FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Recreate surveys table WITH THE CORRECTED 'cgpa_range'
CREATE TABLE surveys (
    survey_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT, -- FK to students
    survey_date DATETIME,
    year_of_study INT,
    cgpa_range VARCHAR(50), -- CORRECTED COLUMN NAME
    marital_status VARCHAR(20),
    anxiety_score INT,
    depression_score INT,
    panic_attack_score INT,
    sought_treatment INT,
    CONSTRAINT fk_student_surveys FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
USE student_mental_health;

-- Temporarily disable foreign key checks to allow dropping tables
SET FOREIGN_KEY_CHECKS = 0;

-- Drop all three tables to ensure a completely clean slate
-- Order matters: child tables first, then parent
DROP TABLE IF EXISTS surveys;
DROP TABLE IF EXISTS demographics;
DROP TABLE IF EXISTS students;

-- Recreate students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT
);

-- Recreate demographics table
CREATE TABLE demographics (
    student_id INT PRIMARY KEY, -- FK to students
    age INT,
    gender VARCHAR(10),
    program_of_study VARCHAR(100),
    CONSTRAINT fk_student_demographics FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Recreate surveys table WITH THE CORRECTED 'cgpa_range'
CREATE TABLE surveys (
    survey_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT, -- FK to students
    survey_date DATETIME,
    year_of_study INT,
    cgpa_range VARCHAR(50), -- CORRECTED COLUMN NAME
    marital_status VARCHAR(20),
    anxiety_score INT,
    depression_score INT,
    panic_attack_score INT,
    sought_treatment INT,
    CONSTRAINT fk_student_surveys FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Re-enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;
USE student_mental_health;

WITH StudentSurveyData AS (
    SELECT
        s.student_id,
        d.age,
        d.gender,
        d.program_of_study,
        su.survey_date,
        su.year_of_study, -- Now directly from the dataset
        su.cgpa_range,
        su.marital_status,
        su.anxiety_score,
        su.depression_score,
        su.panic_attack_score, -- New score
        su.sought_treatment   -- New column
    FROM
        students s
    INNER JOIN
        demographics d ON s.student_id = d.student_id
    INNER JOIN
        surveys su ON s.student_id = su.student_id
)
SELECT
    year_of_study,
    COUNT(DISTINCT student_id) AS number_of_students,
    AVG(anxiety_score) AS average_anxiety_score,
    AVG(depression_score) AS average_depression_score,
    AVG(panic_attack_score) AS average_panic_attack_score,
    AVG(social_connectedness_score) AS average_social_connectedness_score, -- Assuming you still want this, though not in the new dataset
    AVG(CASE WHEN gender = 'Male' THEN anxiety_score END) AS avg_anxiety_male,
    AVG(CASE WHEN gender = 'Female' THEN anxiety_score END) AS avg_anxiety_female,
    AVG(CASE WHEN sought_treatment = 1 THEN anxiety_score END) AS avg_anxiety_sought_treatment,
    AVG(CASE WHEN sought_treatment = 0 THEN anxiety_score END) AS avg_anxiety_not_sought_treatment
FROM
    StudentSurveyData
GROUP BY
    year_of_study
ORDER BY
    year_of_study;

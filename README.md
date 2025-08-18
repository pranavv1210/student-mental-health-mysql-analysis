# Analyzing Students' Mental Health in MySQL (Advanced)

## 1. Project Overview & Objectives

This project builds upon foundational SQL skills to conduct an in-depth analysis of hypothetical international university student mental health data using MySQL. It investigates the impact of **length of stay** on various **mental health diagnostic scores**, alongside demographic factors.

* **Core Objective:** To identify trends and correlations between students' duration at the university and their self-reported anxiety, depression, and social connectedness scores, specifically focusing on international students.
* **Advanced Objectives & Skills Demonstrated:**
    * **Advanced Data Modeling:** Designing and implementing a normalized relational database schema with multiple interconnected tables (`students`, `demographics`, `surveys`).
    * **Complex SQL Queries:** Utilizing `JOIN` operations, advanced date functions (`TIMESTAMPDIFF`), Common Table Expressions (CTEs), Window Functions (`AVG() OVER (...)`), and Conditional Aggregation (`CASE` within `AVG()`) for sophisticated data extraction and analysis.
    * **Data Visualization:** Integrating MySQL data with Python (Pandas, Matplotlib, Seaborn) to create compelling visual insights and trends.
    * **Performance Awareness:** Conceptual understanding of database indexing for optimization.

***

## 2. Data Model

The database is designed with three normalized tables to manage student, demographic, and survey data efficiently.

### `students` Table

Stores core student information.

| Column Name      | Data Type | Description                                        |
| :--------------- | :-------- | :------------------------------------------------- |
| `student_id`     | `INT`     | Unique identifier (Primary Key, Auto-Increment)    |
| `is_international` | `BOOLEAN` | `TRUE` if international, `FALSE` if domestic       |
| `enrollment_date`| `DATE`    | Date student enrolled (used for `length_of_stay`)  |

### `demographics` Table

Stores static demographic information, linked to `students`.

| Column Name          | Data Type     | Description                                                          |
| :------------------- | :------------ | :------------------------------------------------------------------- |
| `student_id`         | `INT`         | Primary Key and Foreign Key referencing `students(student_id)`       |
| `age`                | `INT`         | Student's age                                                        |
| `gender`             | `VARCHAR(10)` | Student's gender (e.g., 'Male', 'Female', 'Non-binary')              |
| `country_of_origin`  | `VARCHAR(50)` | Student's country of origin                                          |
| `program_of_study`   | `VARCHAR(100)`| Academic program/major                                               |
| **Constraint** |               | `FOREIGN KEY (student_id) REFERENCES students(student_id)` (CASCADE) |

### `surveys` Table

Stores individual survey responses, allowing multiple entries per student over time.

| Column Name                | Data Type     | Description                                                          |
| :------------------------- | :------------ | :------------------------------------------------------------------- |
| `survey_id`                | `INT`         | Unique identifier for each survey (Primary Key, Auto-Increment)      |
| `student_id`               | `INT`         | Foreign Key referencing `students(student_id)`                       |
| `survey_date`              | `DATE`        | Date the survey was taken                                            |
| `anxiety_score`            | `INT`         | Diagnostic score for anxiety (0-100, higher = more anxiety)          |
| `depression_score`         | `INT`         | Diagnostic score for depression (0-100, higher = more depression)    |
| `social_connectedness_score` | `INT`         | Score for social connectedness (0-100, higher = more connected)      |
| **Constraint** |               | `FOREIGN KEY (student_id) REFERENCES students(student_id)` (CASCADE) |

***

## 3. Key SQL Queries & Python Integration

All SQL queries are executed against a MySQL database. The primary analysis is then fed into a Python script for visualization.

### Database and Table Creation (SQL)

```sql
-- Drop existing tables (if any) to ensure clean setup
DROP TABLE IF EXISTS surveys;
DROP TABLE IF EXISTS demographics;
DROP TABLE IF EXISTS students;

-- Create students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    is_international BOOLEAN,
    enrollment_date DATE
);

-- Create demographics table with Foreign Key to students
CREATE TABLE demographics (
    student_id INT PRIMARY KEY,
    age INT,
    gender VARCHAR(10),
    country_of_origin VARCHAR(50),
    program_of_study VARCHAR(100),
    CONSTRAINT fk_student_demographics FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create surveys table with Foreign Key to students
CREATE TABLE surveys (
    survey_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    survey_date DATE,
    anxiety_score INT,
    depression_score INT,
    social_connectedness_score INT,
    CONSTRAINT fk_student_surveys FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
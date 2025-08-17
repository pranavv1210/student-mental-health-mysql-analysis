# Analyzing Students' Mental Health in MySQL

## 1. Project Overview & Objectives
This project demonstrates SQL data analysis skills by investigating the relationship between the **length of stay** and **mental health diagnostic scores** for international students at a hypothetical Japanese university.
* **Objective:** To identify if the duration an international student has been at the university impacts their average scores for anxiety, depression, and social connectedness.
* **Skills Demonstrated:** MySQL database setup, table creation, data insertion, data filtering (`WHERE`), data aggregation (`AVG`), and grouping (`GROUP BY`).

---

## 2. Data Model
The analysis is performed on a single `students` table:

### `students` Table Schema
| Column Name              | Data Type | Description                                                    |
| :----------------------- | :-------- | :------------------------------------------------------------- |
| `student_id`             | `INT`     | Unique identifier for each student (Primary Key, Auto-Increment) |
| `is_international`       | `BOOLEAN` | `TRUE` if international student, `FALSE` if domestic         |
| `length_of_stay_months`  | `INT`     | Number of months the student has been enrolled/stayed          |
| `anxiety_score`          | `INT`     | Diagnostic score for anxiety (e.g., 0-100, higher = more anxiety) |
| `depression_score`       | `INT`     | Diagnostic score for depression (e.g., 0-100, higher = more depression) |
| `social_connectedness_score` | `INT`     | Score indicating social connectedness (e.g., 0-100, higher = more connected) |

---

## 3. Key SQL Queries

### Database & Table Creation
```sql
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
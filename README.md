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
````

### Sample Data Insertion (SQL)

Sample data for `students`, `demographics`, and `surveys` tables is inserted to populate the database and enable comprehensive analysis. *(Full INSERT statements are omitted for brevity in this README but are available in the project's SQL files, e.g., `insert_data.sql`.)*

### Core Advanced Analysis Query (SQL using CTEs, JOINS, Date Functions, Conditional Aggregation)

This query pulls data from all three tables, dynamically calculates `length_of_stay_months`, filters for international students, and aggregates average mental health scores, including a gender-based breakdown, grouped by length of stay.

```sql
USE student_mental_health;

WITH StudentSurveyData AS (
    SELECT
        s.student_id,
        d.age,
        d.gender,
        d.program_of_study,
        su.survey_date,
        su.year_of_study,
        su.cypa_range, -- Corrected column name from 'cgpa_range' in previous iterations
        su.marital_status,
        su.anxiety_score,
        su.depression_score,
        su.panic_attack_score,
        su.sought_treatment
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
    -- AVG(social_connectedness_score) AS average_social_connectedness_score, -- Removed as this column is not in the dataset
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
```

### Data Visualization (Python)

A Python script (`visualize_data.py`) connects to the MySQL database, executes the core analysis query, loads the results into a Pandas DataFrame, and generates compelling visualizations using Matplotlib and Seaborn. These plots are saved as PNG files.

  * `mental_health_scores_by_year.png`: Line plot showing average anxiety, depression, and panic attack scores trending over year of study.
  * `anxiety_by_gender_and_year.png`: Bar chart comparing average anxiety scores for male vs. female students by year of study.
  * `anxiety_by_treatment_and_year.png`: Bar chart comparing average anxiety scores for students who sought treatment vs. those who did not, by year of study.

-----

## 4\. Key Findings & Observations

*(**IMPORTANT: Fill this section with YOUR specific observations** from the plots you generated. Describe the trends you see. For example: "The analysis revealed that average anxiety and depression scores for students were highest during their initial year of study, showing a gradual decline thereafter. Conversely, social connectedness scores appeared to improve significantly after 6 months. Gender-based analysis... [add your observations for the second plot].")*

-----

## 5\. Potential Challenges & Learning

  * **Database Normalization:** Designing and implementing a multi-table schema with correct primary and foreign key relationships for data integrity.
  * **Complex SQL:** Mastering `JOIN` clauses, dynamic date calculations (`TIMESTAMPDIFF`), and advanced aggregation techniques (`CASE` statements within `AVG()`, CTEs, and Window Functions) for nuanced analysis.
  * **Data Integration & Visualization:** Connecting MySQL to Python, querying data programmatically, and using data science libraries (Pandas, Matplotlib, Seaborn) to transform raw data into insightful visualizations.
  * **Data Interpretation:** Drawing meaningful conclusions from aggregated and visualized data, especially with synthetic datasets.

-----

## 6\. Real-World Considerations & Future Enhancements

  * **Data Privacy:** In a real-world scenario, student mental health data is highly sensitive. Strict anonymization protocols and adherence to privacy regulations (e.g., GDPR, FERPA) would be paramount.
  * **Limitations of Synthetic Data:** The findings in this project are based on a small, synthetic dataset. Real-world insights would require a larger, validated, and ethically sourced dataset.
  * **Scalability:** For much larger datasets, optimizing queries with appropriate **indexing** (e.g., on `is_international`, `survey_date`, `enrollment_date`) and analyzing query performance using `EXPLAIN` would be critical.

**Future Enhancements:**

  * **Predictive Modeling:** Use Python's machine learning libraries (e.g., scikit-learn) to build models that predict mental health risk based on demographic factors and length of stay.
  * **Interactive Dashboard:** Create an interactive web dashboard (e.g., using Dash or Streamlit in Python, or a BI tool like Tableau/Power BI) to allow users to explore the data dynamically.
  * **Expanded Data:** Incorporate more granular data, such as academic performance, financial aid status, or participation in campus activities, to enrich the analysis.
  * **API Development:** Build a simple API using a framework like Flask or FastAPI in Python to expose the analytical results, allowing other applications to consume this data.
```
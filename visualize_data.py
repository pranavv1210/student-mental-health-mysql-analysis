# Updated visualize_data.py - conceptual
import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Pranav@12102004', # Your MySQL root password
    'database': 'student_mental_health'
}

try:
    cnx = mysql.connector.connect(**DB_CONFIG)
    cursor = cnx.cursor()

    # Your new, updated advanced SQL query
    query = """
    WITH StudentSurveyData AS (
        SELECT
            s.student_id,
            d.age,
            d.gender,
            d.program_of_study,
            su.survey_date,
            su.year_of_study,
            su.cgpa_range,
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
    """

    cursor.execute(query)
    results = cursor.fetchall()
    column_names = [i[0] for i in cursor.description]
    df_analysis = pd.DataFrame(results, columns=column_names)

    print("Data fetched successfully and loaded into DataFrame for analysis:")
    print(df_analysis)

    # --- Data Visualization ---
    sns.set_style("whitegrid")

    # Plot 1: Average Mental Health Scores by Year of Study
    plt.figure(figsize=(12, 6))
    plt.plot(df_analysis['year_of_study'], df_analysis['average_anxiety_score'], marker='o', label='Avg Anxiety')
    plt.plot(df_analysis['year_of_study'], df_analysis['average_depression_score'], marker='o', label='Avg Depression')
    plt.plot(df_analysis['year_of_study'], df_analysis['average_panic_attack_score'], marker='o', label='Avg Panic Attack')
    plt.title('Average Mental Health Scores by Year of Study')
    plt.xlabel('Year of Study')
    plt.ylabel('Average Score (0=No, 1=Yes)') # Update label since scores are binary
    plt.legend()
    plt.grid(True)
    plt.xticks(df_analysis['year_of_study'].unique())
    plt.tight_layout()
    plt.savefig('mental_health_scores_by_year.png')
    plt.show()

    # Plot 2: Average Anxiety by Gender and Year of Study (Bar Chart)
    # Ensure columns exist before plotting, as some might be None due to data sparsity
    plot_df_gender = df_analysis[['year_of_study', 'avg_anxiety_male', 'avg_anxiety_female']].set_index('year_of_study')
    plot_df_gender.plot(kind='bar', figsize=(12, 6))
    plt.title('Average Anxiety Score by Gender and Year of Study')
    plt.xlabel('Year of Study')
    plt.ylabel('Average Anxiety Score (0=No, 1=Yes)')
    plt.xticks(rotation=45)
    plt.legend(['Male', 'Female'])
    plt.tight_layout()
    plt.savefig('anxiety_by_gender_and_year.png')
    plt.show()

    # Plot 3: Average Anxiety by Seeking Treatment and Year of Study (Bar Chart)
    plot_df_treatment = df_analysis[['year_of_study', 'avg_anxiety_sought_treatment', 'avg_anxiety_not_sought_treatment']].set_index('year_of_study')
    plot_df_treatment.plot(kind='bar', figsize=(12, 6))
    plt.title('Average Anxiety Score by Seeking Treatment and Year of Study')
    plt.xlabel('Year of Study')
    plt.ylabel('Average Anxiety Score (0=No, 1=Yes)')
    plt.xticks(rotation=45)
    plt.legend(['Sought Treatment', 'Did Not Seek Treatment'])
    plt.tight_layout()
    plt.savefig('anxiety_by_treatment_and_year.png')
    plt.show()


except mysql.connector.Error as err:
    if err.errno == mysql.connector.errorcode.ER_ACCESS_DENIED_ERROR:
        print("Error: Something is wrong with your user name or password.")
    elif err.errno == mysql.connector.errorcode.ER_BAD_DB_ERROR:
        print("Error: Database does not exist.")
    else:
        print(f"An unexpected MySQL error occurred: {err}")
except Exception as e:
    print(f"An unexpected Python error occurred: {e}")
finally:
    if 'cnx' in locals() and cnx.is_connected():
        cursor.close()
        cnx.close()
        print("MySQL connection closed.")
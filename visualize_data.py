import mysql.connector
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Pranav@12102004',
    'database': 'student_mental_health'
}

try:
    cnx = mysql.connector.connect(**DB_CONFIG)
    cursor = cnx.cursor()

    query = """
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
    """

    cursor.execute(query)

    results = cursor.fetchall()

    column_names = [i[0] for i in cursor.description]

    df = pd.DataFrame(results, columns=column_names)

    print("Data fetched successfully and loaded into DataFrame:")
    print(df)

    sns.set_style("whitegrid")

    plt.figure(figsize=(12, 6))
    plt.plot(df['length_of_stay_months'], df['average_anxiety_score'], marker='o', label='Average Anxiety')
    plt.plot(df['length_of_stay_months'], df['average_depression_score'], marker='o', label='Average Depression')
    plt.plot(df['length_of_stay_months'], df['average_social_connectedness_score'], marker='o', label='Average Social Connectedness')
    plt.title('Average Mental Health Scores by Length of Stay (International Students)')
    plt.xlabel('Length of Stay (Months)')
    plt.ylabel('Average Score')
    plt.legend()
    plt.grid(True)
    plt.xticks(df['length_of_stay_months'].unique())
    plt.tight_layout()
    plt.savefig('mental_health_scores_by_stay.png')
    plt.show()

    df_anxiety_gender = df[['length_of_stay_months', 'avg_anxiety_male', 'avg_anxiety_female']].set_index('length_of_stay_months')
    df_anxiety_gender.plot(kind='bar', figsize=(12, 6))
    plt.title('Average Anxiety Score by Gender and Length of Stay')
    plt.xlabel('Length of Stay (Months)')
    plt.ylabel('Average Anxiety Score')
    plt.xticks(rotation=45)
    plt.legend(['Male', 'Female'])
    plt.tight_layout()
    plt.savefig('anxiety_by_gender_and_stay.png')
    plt.show()

except mysql.connector.Error as err:
    if err.errno == mysql.connector.errorcode.ER_ACCESS_DENIED_ERROR:
        print("Something is wrong with your user name or password")
    elif err.errno == mysql.connector.errorcode.ER_BAD_DB_ERROR:
        print("Database does not exist")
    else:
        print(err)
finally:
    if 'cnx' in locals() and cnx.is_connected():
        cursor.close()
        cnx.close()
        print("MySQL connection closed.")
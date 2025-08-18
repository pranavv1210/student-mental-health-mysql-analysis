import pandas as pd
import mysql.connector
from datetime import datetime

# Database Connection Details
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Pranav@12102004', # Your MySQL root password
    'database': 'student_mental_health'
}

# 1. Load the CSV Data
csv_file_path = 'Student Mental health.csv' # Make sure this file is in the same directory as your script
try:
    df = pd.read_csv(csv_file_path)
    print("CSV loaded successfully. Initial shape:", df.shape)
except FileNotFoundError:
    print(f"Error: The file '{csv_file_path}' was not found. Please ensure it's in the same directory.")
    exit()

# 2. Data Cleaning and Transformation

# 2.1 Rename columns for SQL-friendliness
df.columns = [
    'timestamp', 'gender', 'age', 'course', 'year_of_study', 'cgpa_range',
    'marital_status', 'depression', 'anxiety', 'panic_attack', 'sought_treatment'
]
print("\nColumns renamed.")

# 2.2 Handle Missing Age Value (fill with median, or drop)
df.dropna(subset=['age'], inplace=True)
df['age'] = df['age'].astype(int)
print(f"\nHandled missing age. New shape: {df.shape}")

# 2.3 Convert 'Yes'/'No' to 1/0 for mental health scores and treatment
binary_cols = ['depression', 'anxiety', 'panic_attack', 'sought_treatment']
for col in binary_cols:
    df[col] = df[col].map({'Yes': 1, 'No': 0}).astype(int)
print("\n'Yes'/'No' converted to 1/0.")

# 2.4 Parse 'timestamp' to datetime objects using 'mixed' format for robustness
df['timestamp'] = pd.to_datetime(df['timestamp'], format='mixed', dayfirst=False)
print("\nTimestamp column parsed to datetime.")

# 2.5 Convert 'year_of_study' (e.g., 'year 1' to 1)
df['year_of_study'] = df['year_of_study'].str.extract('(\d+)').astype(int)
print("\n'year_of_study' extracted to integer.")

print("\nTransformed DataFrame head:")
print(df.head())

# 3. Connect to MySQL and Insert Data
try:
    cnx = mysql.connector.connect(**DB_CONFIG)
    cursor = cnx.cursor()

    # Disable foreign key checks temporarily for easier insertion order
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
    cnx.commit()

    # 3.1 Insert into `students` table
    # Assign unique student IDs based on the DataFrame index after cleaning
    student_ids = []
    for index in range(len(df)):
        cursor.execute("INSERT INTO students () VALUES ()")
        student_ids.append(cursor.lastrowid) # Get the last inserted ID
    df['student_id'] = student_ids # Add generated student_ids back to the DataFrame
    print(f"\nInserted {len(student_ids)} unique students into 'students' table.")

    # 3.2 Insert into `demographics` table
    demographics_df = df[['student_id', 'age', 'gender', 'course']].drop_duplicates(subset=['student_id'])
    for index, row in demographics_df.iterrows():
        try:
            insert_query = """
            INSERT INTO demographics (student_id, age, gender, program_of_study)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE age = VALUES(age), gender = VALUES(gender), program_of_study = VALUES(program_of_study)
            """
            cursor.execute(insert_query, (row['student_id'], row['age'], row['gender'], row['course']))
        except mysql.connector.Error as err:
            print(f"Error inserting demographics for student_id {row['student_id']}: {err}")
    print(f"Inserted {len(demographics_df)} records into 'demographics' table.")

    # 3.3 Insert into `surveys` table (using 'cypa_range' to match your existing DB schema)
    for index, row in df.iterrows():
        try:
            insert_query = """
            INSERT INTO surveys (student_id, survey_date, year_of_study, cypa_range, marital_status,
                                 anxiety_score, depression_score, panic_attack_score, sought_treatment)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (
                row['student_id'], row['timestamp'], row['year_of_study'],
                row['cgpa_range'], # This refers to the DataFrame column 'cgpa_range'
                row['marital_status'], row['anxiety'],
                row['depression'], row['panic_attack'], row['sought_treatment']
            ))
        except mysql.connector.Error as err:
            print(f"Error inserting survey for student_id {row['student_id']}: {err}")
    print(f"Inserted {len(df)} records into 'surveys' table.")

    # Re-enable foreign key checks
    cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
    cnx.commit()
    print("\nAll data imported and changes committed.")

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
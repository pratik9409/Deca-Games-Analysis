# Deca Games Google Play Store Analysis

## [Dashboard](https://public.tableau.com/app/profile/pratik.arvind.abnave/viz/DecaGamesAnalysisDashbaord/Dashboard1)

![deca](https://github.com/user-attachments/assets/df038073-a2a9-4343-839f-a7af925cd590)


## Project Overview

This project aims to analyze data from the Google Play Store, including both app metadata and user reviews. By utilizing both Python and SQL, we can generate insights about app performance, user sentiment, and the impact of various features (like pricing or genre) on user ratings and installs.

### Key Datasets

- **App Metadata**: Information about 21 different apps, such as their titles, installation numbers, ratings, developer information, and more.
- **User Reviews**: Reviews associated with these apps, detailing user feedback, review scores, and timestamps.

### Features of the Project

1. **Data Analysis**: Extracting key insights, such as the correlation between the number of installs and app ratings.
2. **Sentiment Analysis**: Performing text analysis on user reviews to gauge overall sentiment.
3. **SQL Integration**: Querying and filtering app data and reviews using SQL for more complex analysis.
4. **Data Visualization**: Creating visual representations of app performance, review trends, and user engagement metrics.

---

## Getting Started

### Prerequisites

- Python 3.x
- Jupyter Notebook (optional for running Python code)
- SQLite or any other SQL-based database
- Required Python Libraries:
    - `pandas`
    - `matplotlib`
    - `sqlite3`

### Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/google-play-store-analysis.git
    cd google-play-store-analysis
    ```

2. **Install the required dependencies**:
    ```bash
    pip install pandas matplotlib sqlite3
    ```

3. **Download the datasets**:
    Ensure the following datasets are in the project directory:
    - `google_play_store_app_clean_utf8.csv`
    - `google_play_store_reviews_clean_utf8.csv`

---

## Usage

### Python Code Explanation

1. **Data Loading and Cleaning**: 
    The Python script loads the app and review datasets using `pandas` and performs basic cleaning, such as handling missing values or correcting data types.

    Example:
    ```python
    import pandas as pd

    apps_data = pd.read_csv('google_play_store_app_clean_utf8.csv')
    reviews_data = pd.read_csv('google_play_store_reviews_clean_utf8.csv')

    # Display the first few rows of each dataset
    print(apps_data.head())
    print(reviews_data.head())
    ```

2. **Data Analysis**:
    The Python code analyzes the relationship between app ratings and the number of installs, developer activity, or whether an app is free or paid. We also look into user sentiments based on review scores.

    Example:
    ```python
    avg_rating = apps_data['score'].mean()
    paid_apps = apps_data[apps_data['free'] == 0]
    print(f"Average Rating: {avg_rating}")
    print(f"Number of Paid Apps: {len(paid_apps)}")
    ```

3. **Visualization**:
    Visualize the correlation between app ratings and the number of installs:
    ```python
    import matplotlib.pyplot as plt

    plt.scatter(apps_data['installs'], apps_data['score'])
    plt.xlabel('Number of Installs')
    plt.ylabel('App Rating')
    plt.title('Installs vs Rating')
    plt.show()
    ```

### SQL Code Explanation

1. **Database Setup**:
    First, the app and review data are loaded into an SQLite database. Queries are then run to explore various aspects of the data.

    Example (Creating Tables):
    ```sql
    CREATE TABLE apps (
        title TEXT,
        installs INTEGER,
        ratings INTEGER,
        reviews INTEGER,
        score REAL,
        price REAL,
        free INTEGER,
        genre TEXT
    );

    CREATE TABLE reviews (
        reviewId TEXT,
        userName TEXT,
        content TEXT,
        score INTEGER,
        thumbsUpCount INTEGER,
        appId TEXT,
        at DATETIME
    );
    ```

2. **Sample Queries**:
    Querying the most highly rated apps with over 1 million installs:
    ```sql
    SELECT title, installs, score
    FROM apps
    WHERE installs > 1000000
    ORDER BY score DESC;
    ```

    Fetching the latest reviews for a specific app:
    ```sql
    SELECT userName, content, score, at
    FROM reviews
    WHERE appId = 'com.example.app'
    ORDER BY at DESC;
    ```

---

## Contribution Guidelines

1. Fork the repository.
2. Create a new branch.
3. Make your changes and ensure everything is working correctly.
4. Submit a pull request.

---

## License

This project is licensed under the MIT License.

---

## Contact

For any questions, feel free to reach out via [your-email@example.com](mailto:your-email@example.com).

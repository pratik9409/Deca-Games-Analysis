create database decagames;
use decagames;



CREATE TABLE reviews_data (
    reviewId VARCHAR(255),
    userName VARCHAR(255),
    userImage TEXT,
    content TEXT,
    score INT,
    thumbsUpCount INT,
    reviewCreatedVersion VARCHAR(255),
    at DATETIME,
    replyContent TEXT,
    repliedAt VARCHAR(255),
    appVersion VARCHAR(255),
    appId Text CHARACTER SET utf8mb4
);



LOAD DATA INFILE 'D:/decagames/google_play_store_reviews_clean.csv'
INTO TABLE reviews_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT appId, HEX(appId) FROM reviews_data;


UPDATE reviews_data
SET appId = REPLACE(appId, '\r', '');


SELECT appId, HEX(appId) FROM reviews_data;


select * from reviews_data;

select count(*) from reviews_data;


CREATE TABLE app_data (
    title varchar(100),
    descriptionHTML TEXT,
    summary TEXT,
    installs TEXT,
    minInstalls INTEGER,
    realInstalls INTEGER,
    score FLOAT,
    ratings INTEGER,
    reviews INTEGER,
    histogram TEXT,
    price FLOAT,
    free BOOLEAN,
    currency TEXT,
    sale BOOLEAN,
    offersIAP BOOLEAN,
    inAppProductPrice TEXT,
    developer TEXT,
    developerId TEXT,
    developerEmail TEXT,
    developerWebsite TEXT,
    developerAddress TEXT,
    privacyPolicy TEXT,
    genre TEXT,
    genreId TEXT,
    categories TEXT,
    icon TEXT,
    headerImage TEXT,
    screenshots TEXT,
    video TEXT,
    videoImage TEXT,
    contentRating TEXT,
    contentRatingDescription TEXT,
    adSupported BOOLEAN,
    containsAds BOOLEAN,
    released TEXT,
    lastUpdatedOn TEXT,
    updated INTEGER,
    version TEXT,
    comments TEXT,
    appId TEXT,
    url TEXT
);

   
select * from app_data;

LOAD DATA INFILE 'D:/decagames/google_play_store_app_data_clean.csv'
INTO TABLE app_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;



-- Top 5 Apps by Number of Installs
SELECT title, installs
FROM app_data
ORDER BY CAST(REPLACE(installs, ',', '') AS UNSIGNED) DESC
LIMIT 5;


-- Average Rating for Each Genre
SELECT genre, AVG(score) AS average_rating
FROM app_data
GROUP BY genre
ORDER BY average_rating DESC;


-- Distribution of Review Scores for a Specific App
SELECT score, COUNT(*) AS count
FROM reviews_data
WHERE appId = 'com.iugome.lilknights'
GROUP BY score
ORDER BY score DESC;


-- Identify Apps with High Rating but Low Number of Reviews:

SELECT title, score, reviews
FROM app_data
WHERE score > 4.5 AND reviews < 1000
ORDER BY score DESC, reviews ASC;


-- Most Recent Reviews for a Specific App

SELECT userName, content, score, at
FROM reviews_data
WHERE appId = 'com.iugome.lilknights'
ORDER BY at DESC
LIMIT 10;


-- Top 10 Apps by Rating

SELECT title, score, ratings
FROM app_data
ORDER BY score DESC, ratings DESC
LIMIT 10;


-- Apps with the Most Reviews

SELECT title, reviews
FROM app_data
ORDER BY reviews DESC
LIMIT 10;


-- Average Score for Free vs. Paid Apps

SELECT free, AVG(score) AS average_score
FROM app_data
GROUP BY free;


-- Number of Apps Released Each Year

SELECT strftime('%Y', released) AS release_year, COUNT(*) AS app_count
FROM app_data
GROUP BY release_year
ORDER BY release_year DESC;



-- Top 5 Genres by Number of Apps

SELECT genre, COUNT(*) AS app_count
FROM app_data
GROUP BY genre
ORDER BY app_count DESC
LIMIT 5;


-- Average Rating by Content Rating

SELECT contentRating, AVG(score) AS average_score
FROM app_data
GROUP BY contentRating
ORDER BY average_score DESC;


-- Average Thumbs Up per Review per App

SELECT appId, AVG(thumbsUpCount) AS avg_thumbs_up
FROM reviews_data
GROUP BY appId
ORDER BY avg_thumbs_up DESC;


-- Distribution of Review Scores per App

SELECT appId, score, COUNT(*) AS count
FROM reviews_data
GROUP BY appId, score
ORDER BY appId, score DESC;



-- Percentage of Positive Reviews (Score 4 and 5) per App

SELECT appId, 
       SUM(CASE WHEN score >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS positive_review_percentage
FROM reviews_data
GROUP BY appId
ORDER BY positive_review_percentage DESC;


-- Apps with Highest Variability in Review Scores

SELECT appId, STDEV(score) AS score_std_dev
FROM reviews_data
GROUP BY appId
ORDER BY score_std_dev DESC
LIMIT 5;



-- Ratio of Reviews to Ratings

SELECT title, reviews, ratings, 
       CAST(reviews AS FLOAT) / ratings AS reviews_to_ratings_ratio
FROM app_data
WHERE ratings > 0
ORDER BY reviews_to_ratings_ratio DESC;


-- Apps with the Most Recent Updates

SELECT title, lastUpdatedOn
FROM app_data
ORDER BY lastUpdatedOn DESC
LIMIT 10;


-- Apps with High Review Activity in the Last Month
-- error
SELECT appId, COUNT(*) AS recent_review_count
FROM reviews_data
WHERE DATE(at) >= DATE('now', '-1 month')
GROUP BY appId
ORDER BY recent_review_count DESC
LIMIT 10;


-- Breakdown of In-App Purchase Prices

SELECT inAppProductPrice, COUNT(*) AS app_count
FROM app_data
WHERE offersIAP = 1
GROUP BY inAppProductPrice
ORDER BY app_count DESC;



-- Apps with the Most Detailed Descriptions

SELECT title, LENGTH(descriptionHtml) AS description_length
FROM app_data
ORDER BY description_length DESC
LIMIT 10;

-- Rank Apps by Average Rating Within Each Genre

SELECT title, genre, score, 
       RANK() OVER (PARTITION BY genre ORDER BY score DESC) AS genre_rank
FROM app_data;

-- Identify Outliers in App Ratings (Using Z-Score)
-- error
SELECT title, score, AVG(score) OVER () AS mean_score, 
       STDDEV(score) OVER () AS stddev_score,
       (score - AVG(score) OVER ()) / STDDEV(score) OVER () AS z_scores
FROM app_data
HAVING ABS(z_score) > 2;


-- Moving Average of Ratings for Each App (Window Function)

SELECT reviewId, appId, score, 
       AVG(score) OVER (PARTITION BY appId ORDER BY at ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS moving_avg_score
FROM reviews_data;


-- Top 3 Most Frequent Words in Reviews for Each App

SELECT appId, word, word_count
FROM (
    SELECT appId, 
           word, 
           COUNT(*) AS word_count,
           RANK() OVER (PARTITION BY appId ORDER BY COUNT(*) DESC) AS word_rank
    FROM (
        SELECT appId, LOWER(SUBSTRING_INDEX(SUBSTRING_INDEX(content, ' ', numbers.n), ' ', -1)) AS word
        FROM reviews_data
        JOIN (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) numbers 
        ON CHAR_LENGTH(content) - CHAR_LENGTH(REPLACE(content, ' ', '')) >= numbers.n - 1
    ) AS words
    GROUP BY appId, word
) AS ranked_words
WHERE word_rank <= 3;



-- Calculate the Average Score of Each App

SELECT 
    a.title, 
    a.appId, 
    AVG(r.score) AS average_review_score
FROM 
    app_data a
JOIN 
    reviews_data r 
ON 
    a.appId = r.appId
GROUP BY 
    a.appId, a.title
ORDER BY 
    average_review_score DESC;
    
    


-- Identify Apps with Discrepancies Between App Store Score and Review Scores

SELECT 
    a.title, 
    a.score AS app_score, 
    AVG(r.score) AS review_avg_score
FROM 
    app_data a
JOIN 
    reviews_data r 
ON 
    a.appId = r.appId
GROUP BY 
    a.appId, a.title, a.score
HAVING 
    ABS(a.score - AVG(r.score)) > 1
ORDER BY 
    ABS(a.score - AVG(r.score)) DESC;


-- Find Apps with High Ratings but Low Review Activity

SELECT 
    a.title, 
    a.score, 
    COUNT(r.reviewId) AS review_count
FROM 
    app_data a
LEFT JOIN 
    reviews_data r 
ON 
    a.appId = r.appId
GROUP BY 
    a.appId, a.title, a.score
HAVING 
    a.score > 4.5 AND review_count < 10
ORDER BY 
    a.score DESC;



-- Top 10 Apps by Number of Reviews and Their Average Rating

SELECT 
    a.title, 
    COUNT(r.reviewId) AS review_count, 
    AVG(r.score) AS average_review_score
FROM 
    app_data a
JOIN 
    reviews_data r 
ON 
    a.appId = r.appId
GROUP BY 
    a.appId, a.title
ORDER BY 
    review_count DESC, average_review_score DESC
LIMIT 10;



-- Find Apps with Consistent Ratings Across Versions

SELECT 
    a.title, 
    COUNT(DISTINCT r.reviewCreatedVersion) AS version_count, 
    STDDEV(r.score) AS score_stddev
FROM 
    app_data a
JOIN 
    reviews_data r 
ON 
    a.appId = r.appId
GROUP BY 
    a.appId, a.title
HAVING 
    version_count > 1 AND score_stddev < 0.5
ORDER BY 
    score_stddev ASC;

-- Compare the Most Reviewed Version of Apps

SELECT a.title, r.reviewCreatedVersion, COUNT(r.reviewId) AS review_count
FROM app_data a 
JOIN reviews_data r ON a.appId = r.appId
GROUP BY a.title, r.reviewCreatedVersion
ORDER BY review_count DESC;





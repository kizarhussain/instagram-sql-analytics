CREATE DATABASE ig_clone;
USE ig_clone;

CREATE TABLE users (
  id INT AUTO_INCREMENT,
  username VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY(id)
);

CREATE TABLE photos (
  id INT AUTO_INCREMENT,
  image_url VARCHAR(255) NOT NULL,
  user_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY(id),
  FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE comments (
  id INT AUTO_INCREMENT,
  comment_text VARCHAR(255) NOT NULL,
  user_id INT NOT NULL,
  photo_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY(id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(photo_id) REFERENCES photos(id)
);

CREATE TABLE likes (
  user_id INT NOT NULL,
  photo_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY(user_id, photo_id),
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(photo_id) REFERENCES photos(id)
);

CREATE TABLE follows (
  follower_id INT NOT NULL,
  followee_id INT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY(follower_id, followee_id),
  FOREIGN KEY(follower_id) REFERENCES users(id),
  FOREIGN KEY(followee_id) REFERENCES users(id)
);

CREATE TABLE tags (
  id INT AUTO_INCREMENT,
  tag_name VARCHAR(255) UNIQUE,
  created_at TIMESTAMP DEFAULT NOW(),
  PRIMARY KEY(id)
);

CREATE TABLE photo_tags (
  photo_id INT NOT NULL,
  tag_id INT NOT NULL,
  PRIMARY KEY(photo_id, tag_id),
  FOREIGN KEY(photo_id) REFERENCES photos(id),
  FOREIGN KEY(tag_id) REFERENCES tags(id)
);

-- Q1: We want to reward our users who have been around the longest, 
--     Find the 5 oldest users.
SELECT username AS oldest_users FROM users
    ORDER BY created_at LIMIT 5;

-- Q2: What day of the week do most users register on?
--     We need to figure out when to schedule an ad campgain
SELECT 
    DAYNAME(created_at) AS day,
    COUNT(*) AS register_day_count_for_ad_campaign
FROM users 
    GROUP BY day
    ORDER BY register_day_count_for_ad_campaign DESC LIMIT 2;

-- Q3: We want to target our inactive users with an email campaign.
--     Find the users who have never posted a photo
SELECT username AS inactive_user_for_eamil_campagin FROM users 
    LEFT JOIN photos ON users.id = photos.user_id 
    WHERE photos.id IS NULL;
    
-- Q4: We're running a new contest to see who can get the most likes on a single photo. 
--     WHO WON??!!
SELECT 
    users.username,
    photos.id,
    photos.image_url,
    COUNT(*) AS total_likes
FROM photos
INNER JOIN likes
    ON likes.photo_id = photos.id
INNER JOIN users
    ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY total_likes DESC 
LIMIT 1;

-- Q5: Our Investors want to know...how many times does the average user post?
-- formula: total number of photos / total number of users
SELECT (SELECT Count(*) FROM photos) / 
       (SELECT Count(*) FROM users) AS avg; 

-- Q6: A brand wants to know which hashtags to use in a post, What are the top 5 most commonly used hashtags?
SELECT 
    tags.tag_name,
    COUNT(*) AS most_used_hastags
FROM photo_tags
    INNER JOIN tags ON photo_tags.tag_id = tags.id
GROUP BY photo_tags.tag_id
ORDER BY 2 DESC 
LIMIT 5;

-- Q7: We have a small problem with bots on our site...Find users who have liked every single photo on the site
SELECT 
    username,
    COUNT(*) AS num_likes
FROM users
    INNER JOIN likes ON users.id = likes.user_id
GROUP BY likes.user_id
HAVING num_likes = (SELECT COUNT(*) FROM photos);

-- Q8: We also have a problem with celebrities, Find users who have never commented on a photo
SELECT users.username AS celebrity FROM users
    LEFT JOIN comments ON users.id = comments.user_id
    WHERE comments.comment_text IS NULL 

-- Q9: Find the percentage of our users who have either never commented on a photo or have commented on every photo
CREATE VIEW vw_celebrity AS 
    SELECT users.username AS celebrity FROM users
    LEFT JOIN comments ON users.id = comments.user_id
    WHERE comments.comment_text IS NULL;

CREATE VIEW vw_bots_comment AS
    SELECT username, COUNT(comment_text) AS user_comment  FROM users
        INNER JOIN comments ON users.id = comments.user_id
        GROUP BY comments.user_id 
        HAVING user_comment = (SELECT COUNT(*) FROM photos);

SELECT ((SELECT COUNT(*) FROM vw_celebrity) + (SELECT COUNT(*) FROM vw_bots_comment))  / 
        (SELECT COUNT(*) FROM users) AS percent
    






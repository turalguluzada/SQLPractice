DROP DATABASE IF EXISTS film_platform_simple;
CREATE DATABASE film_platform_simple CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE film_platform_simple;

CREATE TABLE Users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Movies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  release_year YEAR,
  duration_min SMALLINT,
  language VARCHAR(50),
  rating_avg DECIMAL(3,2) DEFAULT 0.00,
  rating_count INT DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Genres (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE MovieGenres (
  movie_id INT NOT NULL,
  genre_id INT NOT NULL,
  PRIMARY KEY (movie_id, genre_id),
  FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE,
  FOREIGN KEY (genre_id) REFERENCES Genres(id) ON DELETE CASCADE
);

CREATE TABLE Ratings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  movie_id INT NOT NULL,
  rating TINYINT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY ux_user_movie (user_id, movie_id),
  FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE,
  CHECK (rating BETWEEN 1 AND 10)
);

CREATE TABLE Watchlist (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  movie_id INT NOT NULL,
  added_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY ux_wl_user_movie (user_id, movie_id),
  FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
  FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE
);

-- Indexlər (sadə)
CREATE INDEX idx_movies_title ON Movies(title);
CREATE INDEX idx_genres_name ON Genres(name);

-- Nümunə dəyərlər
INSERT INTO Users (username, email, password_hash) VALUES
('tural','tural@example.com','pw_hash'),
('ali','ali@example.com','pw_hash'),
('mina','mina@example.com','pw_hash');

INSERT INTO Genres (name) VALUES ('Action'),('Comedy'),('Drama'),('Sci-Fi');

INSERT INTO Movies (title, description, release_year, duration_min, language) VALUES
('Space Quest', 'Space exploration.', 2020, 130, 'English'),
('Laugh Riot', 'Fast comedy.', 2019, 95, 'English'),
('Home Story', 'Family drama.', 2021, 110, 'Azerbaijani'),
('Tech Edge', 'Tech thriller.', 2022, 105, 'English');

INSERT INTO MovieGenres (movie_id, genre_id) VALUES
(1,4),(1,1),
(2,2),
(3,3),
(4,4),(4,5) -- note: if genre 5 doesn't exist it's fine to remove; kept as example

-- Əvvəlcədən bəzi ratinglər
INSERT INTO Ratings (user_id, movie_id, rating) VALUES
(1,1,9),
(2,1,8),
(1,2,7),
(3,3,8);

-- Watchlist nümunəsi
INSERT INTO Watchlist (user_id, movie_id) VALUES
(1,4),(1,3);

-- Başlanğıc üçün Movies.rating_* sahələrini yenilə
UPDATE Movies m
LEFT JOIN (
  SELECT movie_id, ROUND(AVG(rating),2) AS avg_rating, COUNT(*) AS cnt
  FROM Ratings GROUP BY movie_id
) r ON m.id = r.movie_id
SET m.rating_avg = COALESCE(r.avg_rating,0), m.rating_count = COALESCE(r.cnt,0);

-- Funksiya: filmin ortalama qiyməti
DELIMITER $$
CREATE FUNCTION fn_get_movie_avg(mid INT) RETURNS DECIMAL(3,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE a DECIMAL(3,2);
  SELECT COALESCE(ROUND(AVG(rating),2),0) INTO a FROM Ratings WHERE movie_id = mid;
  RETURN a;
END$$
DELIMITER ;

-- Procedure: istifadəçi üçün qiymətləndirmə əlavə et/yenilə və cache-i yenilə
DELIMITER $$
CREATE PROCEDURE sp_rate_movie(IN p_user INT, IN p_movie INT, IN p_rating TINYINT)
BEGIN
  IF p_rating < 1 OR p_rating > 10 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'rating out of range';
  END IF;

  INSERT INTO Ratings (user_id, movie_id, rating)
  VALUES (p_user, p_movie, p_rating)
  ON DUPLICATE KEY UPDATE rating = p_rating, created_at = CURRENT_TIMESTAMP;

  UPDATE Movies m
  SET m.rating_count = (SELECT COUNT(*) FROM Ratings WHERE movie_id = p_movie),
      m.rating_avg = (SELECT COALESCE(ROUND(AVG(rating),2),0) FROM Ratings WHERE movie_id = p_movie)
  WHERE m.id = p_movie;
END$$
DELIMITER ;

-- Procedure: sadə axtarış (title döngüsü və janr üzrə)
DELIMITER $$
CREATE PROCEDURE sp_search_movies(IN p_title VARCHAR(255), IN p_genre VARCHAR(100))
BEGIN
  SELECT DISTINCT m.*
  FROM Movies m
  LEFT JOIN MovieGenres mg ON m.id = mg.movie_id
  LEFT JOIN Genres g ON mg.genre_id = g.id
  WHERE (p_title IS NULL OR p_title = '' OR m.title LIKE CONCAT('%', p_title, '%'))
    AND (p_genre IS NULL OR p_genre = '' OR g.name = p_genre)
  ORDER BY m.rating_avg DESC, m.rating_count DESC;
END$$
DELIMITER ;

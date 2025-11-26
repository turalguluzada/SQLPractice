CREATE DATABASE SchoolDB
USE SchoolDB

CREATE TABLE Students(
Id INT PRIMARY KEY IDENTITY,
FullName NVARCHAR(100) NOT NULL,
Age INT,
Email VARCHAR(100) UNIQUE,
Score INT DEFAULT 0,
CHECK(Age>=6 AND Age<=20),
CHECK(Score>=0 AND Score<=100)
)

INSERT INTO Students 
VALUES
('Nigar Huseynova',18,'nigarhuseynova88@gmail.com',72),
('Samir Aliyev',14,'samiraliyev21@yahoo.com',83),
('Leyla Karimova',10,'leylakr123@hotmail.com',55),
('Murad Ismayilov',13,'muradismayilov77@gmail.com',47),
('Sevinc Quliyeva',8,'sevincquliyeva09@gmail.com',68)

ALTER TABLE Students
ADD Course INT
SELECT*FROM Students

UPDATE Students
SET Email = 'tural@gmail.com'
WHERE Id = 1

DELETE FROM Students
WHERE(Email = 'tural@gmail.com')

ALTER TABLE Students
ADD CONSTRAINT SchoolDB_Students_Score
CHECK (Score % 5 = 0)

CREATE TABLE AnotherStudents(
Id INT PRIMARY KEY IDENTITY,
FullName NVARCHAR(100) NOT NULL,
Score INT DEFAULT 0
)

INSERT INTO AnotherStudents
SELECT FullName,Score from Students
WHERE(Score > 90)

SELECT*FROM AnotherStudents
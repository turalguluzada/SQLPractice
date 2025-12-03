CREATE DATABASE computer_store;
USE computer_store;

CREATE TABLE Branch (
  id INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(100),
  address VARCHAR(255)
);

CREATE TABLE Categories (
  id INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE Brands (
  id INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(100)
);

CREATE TABLE Models (
  id INT IDENTITY(1,1) PRIMARY KEY,
  name VARCHAR(100),
  brand_id INT,
  category_id INT,
  CONSTRAINT FK_Models_Brands FOREIGN KEY (brand_id) REFERENCES Brands(id),
  CONSTRAINT FK_Models_Categories FOREIGN KEY (category_id) REFERENCES Categories(id)
);

CREATE TABLE Products (
  id INT IDENTITY(1,1) PRIMARY KEY,
  model_id INT,
  sku VARCHAR(100),
  price DECIMAL(10,2),
  cost DECIMAL(10,2),
  qty INT DEFAULT 0,
  CONSTRAINT FK_Products_Models FOREIGN KEY (model_id) REFERENCES Models(id)
);

CREATE TABLE Employers (
  id INT IDENTITY(1,1) PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  middle_name VARCHAR(50),
  dob DATE,
  salary DECIMAL(10,2),
  branch_id INT,
  CONSTRAINT FK_Employers_Branch FOREIGN KEY (branch_id) REFERENCES Branch(id)
);

CREATE TABLE Sales (
  id INT IDENTITY(1,1) PRIMARY KEY,
  sale_date DATE,
  product_id INT,
  employee_id INT,
  branch_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  total_amount DECIMAL(12,2),
  CONSTRAINT FK_Sales_Products FOREIGN KEY (product_id) REFERENCES Products(id),
  CONSTRAINT FK_Sales_Employers FOREIGN KEY (employee_id) REFERENCES Employers(id),
  CONSTRAINT FK_Sales_Branch FOREIGN KEY (branch_id) REFERENCES Branch(id)
);

INSERT INTO Branch (name,address) VALUES
 ('Baku Center','Nizami 10'),
 ('Sumgayit Mall','Central 3'),
 ('Ganja Outlet','M. Huseyn 5'),
 ('Sheki Shop','Yunus Emre 2'),
 ('Nakhchivan Point','Rza 8');

INSERT INTO Categories (name) VALUES
 ('Notebook'),
 ('Desktop'),
 ('Accessory'),
 ('Monitor'),
 ('Printer');

INSERT INTO Brands (name) VALUES
 ('Lenovo'),
 ('Acer'),
 ('Asus'),
 ('HP'),
 ('Dell'),
 ('Logitech');

INSERT INTO Models (name,brand_id,category_id) VALUES
 ('Lenovo V14', 1, 1),
 ('Acer Aspire 5', 2, 1),
 ('Asus TUF', 3, 1),
 ('HP EliteDesk', 4, 2),
 ('Dell Inspiron', 5, 1),
 ('Logitech M325 Mouse', 6, 3);

INSERT INTO Products (model_id,sku,price,cost,qty) VALUES
 (1,'L-V14-01',900.00,700.00,12),
 (2,'A-A5-01',1500.00,1100.00,7),
 (3,'AS-TUF-01',2800.00,2200.00,3),
 (4,'HP-ED-01',1200.00,900.00,5),
 (5,'D-INSP-01',1100.00,850.00,8),
 (6,'LOG-M325-01',25.00,8.00,50);

INSERT INTO Employers (first_name,last_name,middle_name,dob,salary,branch_id) VALUES
 ('Murad','Mammadov','Ali', '2000-05-10',1200.00,1),
 ('Elvin','Qurbanov','Rauf','1999-02-20',1000.00,1),
 ('Leyla','Huseynova','Rasim','1996-08-15',1100.00,2),
 ('Amina','Sadigova','Orkhan','2003-12-05',900.00,3),
 ('Samir','Hasanov','Farrukh','1998-11-30',1050.00,4),
 ('Rufat','Ismailov','Nigar','2001-07-22',950.00,5);

INSERT INTO Sales (sale_date, product_id, employee_id, branch_id, quantity, unit_price, total_amount) VALUES
 ('2025-12-03', 1, 1, 1, 2, 900.00, 1800.00),
 ('2025-12-03', 2, 1, 1, 1, 1500.00, 1500.00),  -- Murad total this month 3300
 ('2025-11-23', 6, 2, 1, 10, 25.00, 250.00),
 ('2025-12-03', 3, 3, 2, 1, 2800.00, 2800.00),
 ('2025-10-24', 1, 1, 1, 1, 900.00, 900.00),
 ('2025-12-03', 4, 4, 3, 2, 1200.00, 1200.00),
 ('2025-12-03', 5, 5, 4, 1, 1100.00, 1100.00),
 ('2025-11-28', 2, 2, 1, 1, 1500.00, 1500.00),
 ('2025-12-03', 2, 2, 1, 1, 1500.00, 1500.00),
 ('2025-11-13', 6, 6, 5, 5, 25.00, 125.00),
 ('2025-12-03', 6, 2, 1, 2, 25.00, 500.00),
 ('2025-11-30', 3, 3, 2, 1, 2800.00, 2800.00);

-- Task1
SELECT * FROM [Products]

SELECT p.id, m.name AS Models, b.name AS Brands, c.name AS Categories, p.price, p.qty
FROM Products p
JOIN Models m ON p.model_id = m.id
JOIN Brands b ON m.brand_id = b.id
JOIN Categories c ON m.category_id = c.id;

-- Task2
SELECT * FROM Employers

SELECT e.id, e.first_name, e.last_name, e.middle_name, e.dob, e.salary, br.name AS Branch
FROM Employers e
LEFT JOIN Branch br ON e.branch_id = br.id;

-- Task3
SELECT p.id, m.name AS Models, c.name AS Categories, p.price
FROM Products p
JOIN Models m ON p.model_id = m.id
JOIN Categories c ON m.category_id = c.id;

-- Task4
SELECT * FROM Employers WHERE first_name = 'Murad';

-- Task5
-- DateOfBirth ile etdim
SELECT id, first_name, last_name, DATEDIFF(year, dob, CAST(GETDATE() AS date)) AS age
FROM Employers
WHERE DATEDIFF(year, dob, CAST(GETDATE() AS date)) < 25;

-- Task6
SELECT m.id, m.name AS Models, COALESCE(SUM(p.qty),0) AS stock
FROM Models m
LEFT JOIN Products p ON p.model_id = m.id
GROUP BY m.id, m.name;

-- Task7
SELECT b.name AS brand, m.name AS Models, ISNULL(SUM(p.qty), 0) AS stock
FROM Brands b
JOIN Models m ON m.brand_id = b.id
LEFT JOIN Products p ON p.model_id = m.id
GROUP BY b.name, m.name;

-- Task8
SELECT br.name AS Branch, YEAR(s.sale_date) AS year, MONTH(s.sale_date) AS month, SUM(s.total_amount) AS monthly_total
FROM Sales s
JOIN Branch br ON s.branch_id = br.id
GROUP BY br.name, YEAR(s.sale_date), MONTH(s.sale_date);

-- Task9
SELECT m.id, m.name AS Models, SUM(s.quantity) AS sold_qty
FROM Sales s
JOIN Products p ON s.product_id = p.id
JOIN Models m ON p.model_id = m.id
WHERE YEAR(s.sale_date) = YEAR(GETDATE()) AND MONTH(s.sale_date) = MONTH(GETDATE())
GROUP BY m.id, m.name
ORDER BY sold_qty DESC;

-- Task10
SELECT e.id,
       (e.first_name + ' ' + ISNULL(e.last_name, '')) AS employee,
       ISNULL(SUM(s.total_amount), 0) AS total_sales
FROM Employers e
LEFT JOIN Sales s
  ON s.employee_id = e.id
  AND YEAR(s.sale_date) = YEAR(GETDATE())
  AND MONTH(s.sale_date) = MONTH(GETDATE())
GROUP BY e.id, e.first_name, e.last_name
ORDER BY total_sales ASC;

-- Task11
SELECT e.id,
       (e.first_name + ' ' + ISNULL(e.last_name, '')) AS employee,
       SUM(s.total_amount) AS total_sales
FROM Employers e
JOIN Sales s ON s.employee_id = e.id
WHERE YEAR(s.sale_date) = YEAR(GETDATE()) AND MONTH(s.sale_date) = MONTH(GETDATE())
GROUP BY e.id, e.first_name, e.last_name
HAVING SUM(s.total_amount) > 3000;

-- Task12
SELECT id,
       RTRIM(LTRIM(
         e.first_name + ' ' + ISNULL(e.last_name, '') +
         CASE WHEN e.middle_name IS NULL OR e.middle_name = '' THEN '' ELSE ' ' + e.middle_name END
       )) AS full_name
FROM Employers e;

-- Task13
SELECT m.name,
       m.name + ' (' + CONVERT(VARCHAR(10), LEN(m.name)) + ')' AS name_with_length
FROM Models m;

-- Task14
SELECT p.id, m.name AS Models, p.price
FROM Products p
JOIN Models m ON p.model_id = m.id
ORDER BY p.price DESC;

-- Task15
SELECT p.id, m.name AS model, p.price,
  CASE
    WHEN p.price = (SELECT MAX(price) FROM Products) THEN 'most_expensive'
    WHEN p.price = (SELECT MIN(price) FROM Products) THEN 'cheapest'
    ELSE 'other'
  END AS which
FROM Products p
JOIN Models m ON p.model_id = m.id
WHERE p.price = (SELECT MAX(price) FROM Products) OR p.price = (SELECT MIN(price) FROM Products);

-- Task16
SELECT p.id, m.name AS Models, p.price,
  CASE
    WHEN p.price < 1000 THEN 'affordable'
    WHEN p.price BETWEEN 1000 AND 2500 THEN 'mid-range'
    ELSE 'expensive'
  END AS price_category
FROM Products p
JOIN Models m ON p.model_id = m.id;

-- Task17
SELECT ISNULL(SUM(total_amount), 0) AS total_sales_this_month
FROM Sales
WHERE YEAR(sale_date) = YEAR(GETDATE()) AND MONTH(sale_date) = MONTH(GETDATE());

-- Task18
SELECT e.id, e.first_name, e.last_name, SUM(s.total_amount) AS total_sales
FROM Employers e
JOIN Sales s ON s.employee_id = e.id
WHERE YEAR(s.sale_date) = YEAR(GETDATE()) AND MONTH(s.sale_date) = MONTH(GETDATE())
GROUP BY e.id, e.first_name, e.last_name
ORDER BY total_sales DESC;

-- Task19
SELECT e.id, e.first_name, e.last_name,
       SUM((s.unit_price - p.cost) * s.quantity) AS total_profit
FROM Employers e
JOIN Sales s ON s.employee_id = e.id
JOIN Products p ON s.product_id = p.id
WHERE YEAR(s.sale_date) = YEAR(GETDATE()) AND MONTH(s.sale_date) = MONTH(GETDATE())
GROUP BY e.id, e.first_name, e.last_name
ORDER BY total_profit DESC;

-- Task20
-- Komek almisam
WITH totals AS (
  SELECT s.employee_id, SUM(s.total_amount) AS tot
  FROM Sales s
  WHERE YEAR(s.sale_date) = YEAR(GETDATE()) AND MONTH(s.sale_date) = MONTH(GETDATE())
  GROUP BY s.employee_id
),
max_tot AS (
  SELECT MAX(tot) AS mx FROM totals
)
UPDATE Employers
SET salary = salary * 1.5
WHERE id IN (
  SELECT employee_id FROM totals WHERE tot = (SELECT mx FROM max_tot)
);
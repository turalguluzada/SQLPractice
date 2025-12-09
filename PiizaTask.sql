CREATE DATABASE PizzaMizzaDB

CREATE TABLE Pizzas(
ID INT PRIMARY KEY IDENTITY,
Name NVARCHAR(100),
Type NVARCHAR(50)
)

INSERT INTO Pizzas (Name, Type) VALUES
('Margherita', 'Vegetarian'),
('Pepperoni', 'Meat'),
('Chicken BBQ', 'Special'),
('Hawaii', 'Special')


CREATE TABLE Sizes(
ID INT PRIMARY KEY IDENTITY,
Name NVARCHAR(50)
)

INSERT INTO Sizes (Name) VALUES
('Small'),
('Medium'),
('Large')


CREATE TABLE Ingredients(
ID INT PRIMARY KEY IDENTITY,
Name NVARCHAR(70)
)

INSERT INTO Ingredients (Name) VALUES
('Mozzarella'),
('Pomidor sousu'),
('Pendir'),
('Göb?l?k'),
('Zeytun'),
('Kolbasa'),
('Vetçina'),
('Toyuq'),
('So?an'),
('Qo?alotu'),
('Holland pendiri'),
('Pepperoni'),
('Ananas')


CREATE TABLE PizzaIngredients(
ID INT IDENTITY PRIMARY KEY,
PizzaID INT FOREIGN KEY REFERENCES Pizzas(ID),
IngredientID INT FOREIGN KEY REFERENCES Ingredients(ID)
)

INSERT INTO PizzaIngredients (PizzaID, IngredientID) VALUES
(1, 1), 
(1, 2),  
(1, 3),
(2, 2),  
(2, 11), 
(2, 12),
(3, 8), 
(3, 4),  
(3, 9),  
(3, 3),
(4, 7), 
(4, 1), 
(4, 13)



CREATE TABLE PizzaPrices(
ID INT IDENTITY PRIMARY KEY,
PizzaID INT FOREIGN KEY REFERENCES Pizzas(ID),
SizeID INT FOREIGN KEY REFERENCES Sizes(ID),
Price DECIMAL
)

INSERT INTO PizzaPrices (PizzaId, SizeId, Price) VALUES
(1, 1, 6.50),
(1, 2, 8.00),
(1, 3, 9.50),
(2, 1, 7.50),
(2, 2, 9.50),
(2, 3, 11.00),
(3, 2, 10.00),
(3, 3, 12.50),
(4, 1, 7.00),
(4, 2, 9.00),
(4, 3, 10.50)
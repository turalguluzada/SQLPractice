CREATE DATABASE GroupTaskDb;

USE GroupTaskDb;

CREATE TABLE Customers (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NULL,
    Phone NVARCHAR(50) NULL
);

CREATE TABLE Categories (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(400) NULL
);

CREATE TABLE Suppliers (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(200) NOT NULL,
    ContactInfo NVARCHAR(400) NULL
);

CREATE TABLE Products (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(200) NOT NULL,
    Description NVARCHAR(400) NULL,
    Price DECIMAL(10,2) NOT NULL,
    CategoryId INT NULL  
);

CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY,
    CustomerId INT NULL, 
    OrderDate DATETIME NULL,
    Status NVARCHAR(50) NULL
);

CREATE TABLE OrderItems (
    Id INT PRIMARY KEY IDENTITY,
    OrderId INT NULL,     
    ProductId INT NULL,   
    Quantity INT NULL,
    UnitPrice DECIMAL(10,2) NULL
);

CREATE TABLE ProductSuppliers (
    Id INT PRIMARY KEY IDENTITY,
    ProductId INT NULL,  
    SupplierId INT NULL    
);
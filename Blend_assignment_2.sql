CREATE DATABASE RetailSalesDB;
USE RetailSalesDB;
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    ship_city VARCHAR(255),
    ship_state VARCHAR(255),
    ship_country VARCHAR(255)
);

CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    SKU VARCHAR(255) UNIQUE,
    Style VARCHAR(255),
    Category VARCHAR(255)
);

CREATE TABLE Orders (
    OrderID VARCHAR(255) PRIMARY KEY,
    OrderDate DATE,
    Fulfilment VARCHAR(255),
    Status VARCHAR(255),
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    DetailID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID VARCHAR(255),
    ProductID INT,
    Qty INT,
    Amount DOUBLE,
    Revenue DOUBLE,
    Profit DOUBLE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

USE RetailSalesDB;
SELECT COUNT(*) FROM imported_sales;

DESCRIBE imported_sales;

INSERT INTO Customers (ship_city, ship_state, ship_country)
SELECT DISTINCT 
    `ship-city`,
    `ship-state`,
    `ship-country`
FROM imported_sales
WHERE `ship-city` IS NOT NULL 
  AND `ship-state` IS NOT NULL;

INSERT INTO Products (SKU, Style, Category)
SELECT DISTINCT 
    SKU,
    Style,
    Category
FROM imported_sales
WHERE SKU IS NOT NULL;

INSERT INTO Orders (OrderID, OrderDate, Fulfilment, Status, CustomerID)
SELECT DISTINCT
    `Order ID`,
    `Date`,
    Fulfilment,
    Status,
    c.CustomerID
FROM imported_sales i
JOIN Customers c
    ON c.ship_city = i.`ship-city`
   AND c.ship_state = i.`ship-state`
   AND c.ship_country = i.`ship-country`;

INSERT INTO OrderDetails (OrderID, ProductID, Qty, Amount, Revenue, Profit)
SELECT
    i.`Order ID`,
    p.ProductID,
    i.Qty,
    i.Amount,
    i.Revenue,
    i.Profit
FROM imported_sales i
JOIN Products p 
    ON p.SKU = i.SKU;

INSERT INTO Customers (ship_city, ship_state, ship_country)
SELECT DISTINCT 
    COALESCE(`ship-city`, 'Unknown'),
    COALESCE(`ship-state`, 'Unknown'),
    COALESCE(`ship-country`, 'Unknown')
FROM imported_sales
WHERE (`ship-city` IS NULL OR `ship-state` IS NULL)
  AND NOT EXISTS (
        SELECT 1 FROM Customers c
        WHERE c.ship_city = COALESCE(imported_sales.`ship-city`, 'Unknown')
          AND c.ship_state = COALESCE(imported_sales.`ship-state`, 'Unknown')
          AND c.ship_country = COALESCE(imported_sales.`ship-country`, 'Unknown')
      );

INSERT IGNORE INTO Orders (OrderID, OrderDate, Fulfilment, Status, CustomerID)
SELECT 
    `Order ID`,
    `Date`,
    Fulfilment,
    Status,
    c.CustomerID
FROM imported_sales i
LEFT JOIN Customers c
    ON c.ship_city = COALESCE(i.`ship-city`, 'Unknown')
   AND c.ship_state = COALESCE(i.`ship-state`, 'Unknown')
   AND c.ship_country = COALESCE(i.`ship-country`, 'Unknown');
   
   
   SELECT COUNT(*) FROM OrderDetails;
SELECT * FROM OrderDetails LIMIT 10;

SELECT 
    p.SKU,
    DATE_FORMAT(o.OrderDate, '%Y-%m') AS Month,
    SUM(od.Qty) AS TotalQtySold
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY Month, p.SKU
ORDER BY Month, TotalQtySold DESC;

SELECT 
    c.ship_state AS Region,
    SUM(od.Revenue) AS TotalRevenue
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Customers c ON c.CustomerID = o.CustomerID
GROUP BY Region
ORDER BY TotalRevenue DESC;

SELECT 
    o.CustomerID,
    SUM(od.Revenue) AS TotalSpend
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY o.CustomerID
HAVING TotalSpend > 10000;






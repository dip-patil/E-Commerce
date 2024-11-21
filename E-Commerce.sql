Create Database E_Commerce;

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    phone NVARCHAR(15) UNIQUE NOT NULL,
    address NVARCHAR(255) NOT NULL
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status NVARCHAR(50) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY IDENTITY(1,1),
    product_name NVARCHAR(100) NOT NULL,
    category NVARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

CREATE TABLE OrderItems (
    order_item_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY IDENTITY(1,1),
    order_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method NVARCHAR(50) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

INSERT INTO Customers (name, email, phone, address) VALUES
('Rajesh Kumar', 'rajesh.kumar@example.in', '9876543210', 'Delhi, India'),
('Priya Sharma', 'priya.sharma@example.in', '9123456789', 'Mumbai, Maharashtra'),
('Amit Gupta', 'amit.gupta@example.in', '9008765432', 'Bengaluru, Karnataka');

INSERT INTO Products (product_name, category, price) VALUES
('Samsung Galaxy M14', 'Electronics', 12999.00),
('Levis Jeans', 'Apparel', 2499.00),
('Classmate Notebook', 'Stationery', 50.00);

INSERT INTO Orders (customer_id, order_date, status) VALUES
(1, '2024-11-01', 'Shipped'),
(2, '2024-11-02', 'Delivered'),
(3, '2024-11-03', 'Processing');

INSERT INTO OrderItems (order_id, product_id, quantity, price_at_purchase) VALUES
(1, 1, 1, 12999.00),
(2, 2, 2, 2499.00),
(3, 3, 5, 50.00);

INSERT INTO Payments (order_id, amount, payment_date, payment_method) VALUES
(1, 12999.00, '2024-11-04', 'UPI'),
(2, 4998.00, '2024-11-05', 'Credit Card'),
(3, 250.00, '2024-11-06', 'Cash');

-- 1)Retrieve all customers who haven’t placed any orders yet:

Select c.customer_id,c.name,c.email
from Customers c
inner join Orders o
on c.customer_id=o.customer_id
where o.order_id is null


-- 2)Update the phone number of a customer with a specific customer_id:

UPDATE Customers
SET phone = '9876543210'
WHERE customer_id = 1;


-- 3)List all orders placed in the last 30 days, along with the corresponding customer name and email:

Select c.name,c.email
from Customers c
inner join Orders o on c.customer_id=o.customer_id
where o.order_date >= DATEADD(day,-30,GetDate())


-- 4) Calculate the total number of orders for each customer and display the customer’s name, email, and total order count:

Select c.name,c.email,Count(c.customer_id) as [order count]
from Customers c
inner join Orders o on c.customer_id=o.customer_id
where o.order_id is not null
Group by c.name,c.email



-- 5) Find all orders with a status of "Pending" that were placed more than 7 days ago:

SELECT order_id, customer_id, order_date, status
FROM Orders
WHERE status = 'Pending' AND order_date < DATEADD(DAY, -7, GETDATE());

-- 6) Retrieve all products that have not been ordered yet:

SELECT p.product_id, p.product_name, p.category, p.price
FROM Products p
LEFT JOIN OrderItems oi ON p.product_id = oi.product_id
WHERE oi.order_item_id IS NULL;

-- 7)Find the product category with the highest average price:

SELECT TOP 1 category, AVG(price) AS avg_price
FROM Products
GROUP BY category
ORDER BY avg_price DESC;

-- 8)Calculate the total quantity of each product sold and display the product_name along with the total quantity:

SELECT p.product_name, SUM(oi.quantity) AS total_quantity
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name;

-- 9)Retrieve the total revenue generated from each product, sorted by revenue in descending order:

SELECT p.product_name, SUM(oi.quantity * oi.price_at_purchase) AS total_revenue
FROM OrderItems oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;



-- 10)Find all orders that have been paid using the "Credit Card" payment method and display the customer_name and payment_date:

SELECT c.name AS customer_name, p.payment_date
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
JOIN Customers c ON o.customer_id = c.customer_id
WHERE p.payment_method = 'Credit Card';


-- 11) Calculate the total payment amount received per payment_method:

SELECT payment_method, SUM(amount) AS total_amount
FROM Payments
GROUP BY payment_method;

-- 12) Find the top 3 customers who have spent the most, including their name, total amount, and the number of orders they placed:

SELECT TOP 3 c.name, c.email, SUM(p.amount) AS total_spent, COUNT(o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Payments p ON o.order_id = p.order_id
GROUP BY c.customer_id, c.name, c.email
ORDER BY total_spent DESC;

-- 13) Retrieve all orders where the total amount (sum of price_at_purchase * quantity for all items in the order) exceeds 10,000:

SELECT o.order_id, SUM(oi.quantity * oi.price_at_purchase) AS total_amount
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
GROUP BY o.order_id
HAVING SUM(oi.quantity * oi.price_at_purchase) > 10000;

-- 14) Display the order details (order ID, order date, total amount, and status) for customers who have placed more than 5 orders:

SELECT o.order_id, o.order_date, o.status, 
       SUM(oi.quantity * oi.price_at_purchase) AS total_amount
FROM Orders o
JOIN OrderItems oi ON o.order_id = oi.order_id
WHERE o.customer_id IN (
    SELECT customer_id
    FROM Orders
    GROUP BY customer_id
    HAVING COUNT(order_id) > 5
)
GROUP BY o.order_id, o.order_date, o.status;



-- 15)Find the percentage of orders with "Pending" status out of the total number of orders:

SELECT 
    (SELECT COUNT(*) FROM Orders WHERE status = 'Pending')* 100.0 / COUNT(*) AS pending_percentage
FROM Orders;





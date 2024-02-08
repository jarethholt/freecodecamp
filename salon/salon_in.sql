-- Input file for creating the salon database

-- Connect to the database to create it
DROP DATABASE salon;
CREATE DATABASE salon;
\c salon;

-- Table of services
CREATE TABLE services(
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(20) UNIQUE NOT NULL
);
INSERT INTO services(name) VALUES
    ('Haircut'),
    ('Dye job'),
    ('Shampoo'),
    ('Beard trim'),
    ('Perm');

-- Table of customers
CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    phone VARCHAR(20) UNIQUE NOT NULL,
    name VARCHAR(30) NOT NULL
);

-- Table of appointments
CREATE TABLE appointments(
    appointment_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    service_id INT NOT NULL REFERENCES services(service_id),
    time VARCHAR(10) NOT NULL
);

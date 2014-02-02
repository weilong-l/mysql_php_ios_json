-- create table
CREATE TABLE cities
(
    id INT PRIMARY KEY NOT NULL auto_increment,
    cityName VARCHAR(255),
    cityState VARCHAR(255),
    cityPopulation int,
    country VARCHAR(255)
);
 
-- Insert data into our table
INSERT INTO cities(cityName, cityState, cityPopulation, country)
VALUE ('London', 'London', 8173194, 'United Kingdom');
 
INSERT INTO cities(cityName, cityState, cityPopulation, country)
VALUE ('Bombay', 'Maharashtra', 12478447, 'India');
 
INSERT INTO cities(cityName, cityState, cityPopulation, country)
VALUE ('Kuala Lumpur', 'Federal Territory', 1627172, 'Malaysia');
 
INSERT INTO cities(cityName, cityState, cityPopulation, country)
VALUE ('New York', 'New York', 8336697, 'United States');
 
INSERT INTO cities(cityName, cityState, cityPopulation, country)
VALUE ('Berlin', 'Berlin', 3538652, 'Deutschland');
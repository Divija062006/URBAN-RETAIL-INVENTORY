CREATE TABLE  inventory_forecasting (
    `Date` DATE,
    `Store_ID` VARCHAR(10),
    `Product_ID` VARCHAR(10),
    `Category` VARCHAR(50),
    `Region` VARCHAR(50),
    `Inventory_Level` INT,
    `Units_Sold` INT,
    `Units_Ordered` INT,
    `Demand_Forecast` DECIMAL(7,2),
    `Price` DECIMAL(7,2),
    `Discount` DECIMAL(7,2),
    `Weather_Condition` VARCHAR(20),
    `Holiday_Promotion` BOOLEAN,
    `Competitor_Pricing` DECIMAL(7,2),
    `Seasonality` VARCHAR(20),
    `Store_Record_ID` INT,
    `Product_Record_ID` INT
);

-- 🔸 Step 3: Load the data safely from CSV
LOAD DATA LOCAL INFILE 'C:\\Users\\divig\\OneDrive\\Desktop\\inventory_forecasting.csv'
INTO TABLE inventory_forecasting
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(`Date`, `Store_ID`, `Product_ID`, `Category`, `Region`,
 `Inventory_Level`, `Units_Sold`, `Units_Ordered`, `Demand_Forecast`,
 `Price`, `Discount`, `Weather_Condition`, `Holiday_Promotion`,
 `Competitor_Pricing`, `Seasonality`);

-- 🔸 Step 4: Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- 🔸 Step 5: Assign Store_Record_ID (Store_ID + Region combo)
CREATE TEMPORARY TABLE store_region_ranked AS
SELECT `Store_ID`, Region,
       ROW_NUMBER() OVER (ORDER BY `Store_ID`, Region) AS sid
FROM (SELECT DISTINCT `Store_ID`, Region FROM inventory_forecasting) AS unique_combos;

UPDATE inventory_forecasting inv
JOIN store_region_ranked srr
  ON inv.`Store_ID` = srr.`Store_ID` AND inv.Region = srr.Region
SET inv.Store_Record_ID = srr.sid;

-- 🔸 Step 6: Assign Product_Record_ID (Product_ID + Category combo)
CREATE TEMPORARY TABLE product_category_ranked AS
SELECT `Product_ID`, Category,
       ROW_NUMBER() OVER (ORDER BY `Product_ID`, Category) AS pid
FROM (SELECT DISTINCT `Product_ID`, Category FROM inventory_forecasting) AS unique_combos;

-- Speed up join with index
ALTER TABLE product_category_ranked
ADD INDEX (`Product_ID`, `Category`);

-- Full update (no LIMIT) now that we're safe
UPDATE inventory_forecasting inv
JOIN product_category_ranked pcr
  ON inv.`Product_ID` = pcr.`Product_ID` AND inv.Category = pcr.Category
SET inv.Product_Record_ID = pcr.pid;

-- 🔸 Step 7: Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;
--- Creating subtables
CREATE TABLE stores AS
SELECT Store_Record_ID, Store_ID,Region FROM inventory_forecasting;
ALTER TABLE stores
ADD PRIMARY KEY (Store_Record_ID);
CREATE TABLE products AS
SELECT Product_Record_ID, Product_ID, Category FROM inventory_forecasting;
ALTER TABLE products
ADD PRIMARY KEY (Product_Record_ID);
CREATE TABLE sales AS
SELECT Date, Store_Record_ID, Product_Record_ID, Inventory_Level, Units_Sold, Units_Ordered,Demand_Forecast FROM inventory_forecasting;  
ALTER TABLE sales 
ADD CONSTRAINT fk_Store_Record_ID
FOREIGN KEY (Store_Record_ID)
REFERENCES stores(Store_Record_ID),
ADD CONSTRAINT fk_Product_Record_ID
FOREIGN KEY (Product_Record_ID)
REFERENCES products(Product_Record_ID);
CREATE TABLE price AS
SELECT Date, Store_Record_ID, Product_Record_ID, Price, Discount, Competitor_Pricing FROM inventory_forecasting; 
ALTER TABLE price
ADD CONSTRAINT fk_Store_Record_ID1
FOREIGN KEY (Store_Record_ID)
REFERENCES stores(Store_Record_ID),
ADD CONSTRAINT fk_Product_Record_ID1
FOREIGN KEY (Product_Record_ID)
REFERENCES products(Product_Record_ID);
CREATE TABLE weather_promotion AS
SELECT Date, Store_Record_ID, Product_Record_ID, Seasonality, Weather_Condition, Holiday_Promotion FROM inventory_forecasting; 
ALTER TABLE weather_promotion
ADD CONSTRAINT fk_Store_Record_ID2
FOREIGN KEY (Store_Record_ID)
REFERENCES stores(Store_Record_ID),
ADD CONSTRAINT fk_Product_Record_ID2
FOREIGN KEY (Product_Record_ID)
REFERENCES products(Product_Record_ID);

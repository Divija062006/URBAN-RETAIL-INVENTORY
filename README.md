# Inventory Forecasting Database

## Overview

This project focuses on designing and structuring an **inventory forecasting database** from raw inventory, sales, pricing, weather, and promotion data.

The primary objective was to transform a single raw dataset into a **normalized relational database structure** that separates store information, product information, sales, pricing, and external factors while maintaining relationships between them.

## Dataset

The raw dataset contains information related to:

* Stores and regions
* Products and categories
* Inventory levels
* Units sold and ordered
* Demand forecasts
* Product pricing and discounts
* Competitor pricing
* Weather conditions
* Holiday promotions
* Seasonality

The main table initially contains these attributes together in a single `inventory_forecasting` table.

## Database Design

The project transforms the raw table into multiple related tables based on the different aspects of the inventory system.

### Stores

The `stores` table contains unique store-level information:

```text
Store_Record_ID
Store_ID
Region
```

A unique `Store_Record_ID` is generated for each `Store_ID + Region` combination and is used as the primary key.

### Products

The `products` table contains product-level information:

```text
Product_Record_ID
Product_ID
Category
```

A unique `Product_Record_ID` is generated for each `Product_ID + Category` combination and is used as the primary key.

### Sales

The `sales` table contains the operational inventory and sales information:

```text
Date
Store_Record_ID
Product_Record_ID
Inventory_Level
Units_Sold
Units_Ordered
Demand_Forecast
```

### Price

The `price` table contains pricing-related information:

```text
Date
Store_Record_ID
Product_Record_ID
Price
Discount
Competitor_Pricing
```

### Weather & Promotion

The `weather_promotion` table captures external factors that can influence demand:

```text
Date
Store_Record_ID
Product_Record_ID
Seasonality
Weather_Condition
Holiday_Promotion
```

## Key Design Decisions

### Composite Entity Identification

The raw dataset did not directly provide independent numeric identifiers for stores and products.

To create stable relational keys:

* `Store_Record_ID` was generated from the `Store_ID + Region` combination.
* `Product_Record_ID` was generated from the `Product_ID + Category` combination.

`ROW_NUMBER()` was used to assign unique identifiers to these combinations.

### Relational Structure

The original wide table was decomposed into specialized tables:

```text
                    ┌─────────────┐
                    │   stores    │
                    └──────┬──────┘
                           │
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌─────────┐        ┌─────────┐     ┌──────────────────┐
   │  sales  │        │  price  │     │weather_promotion │
   └────┬────┘        └────┬────┘     └────────┬─────────┘
        │                  │                    │
        └──────────────────┼────────────────────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  products   │
                    └─────────────┘
```

Both `sales`, `price`, and `weather_promotion` reference the `stores` and `products` tables through foreign keys.

This allows store and product information to be maintained separately from transactional and contextual data.

## Data Integrity

Primary keys were established for the `stores` and `products` tables:

```sql
PRIMARY KEY (Store_Record_ID)
PRIMARY KEY (Product_Record_ID)
```

Foreign key constraints were then added to the dependent tables to maintain referential integrity:

```text
sales
 ├── Store_Record_ID → stores
 └── Product_Record_ID → products

price
 ├── Store_Record_ID → stores
 └── Product_Record_ID → products

weather_promotion
 ├── Store_Record_ID → stores
 └── Product_Record_ID → products
```

## Database Schema

```text
inventory_forecasting
        │
        ├── stores
        │     └── Store_Record_ID (PK)
        │
        ├── products
        │     └── Product_Record_ID (PK)
        │
        ├── sales
        │     ├── Store_Record_ID (FK)
        │     └── Product_Record_ID (FK)
        │
        ├── price
        │     ├── Store_Record_ID (FK)
        │     └── Product_Record_ID (FK)
        │
        └── weather_promotion
              ├── Store_Record_ID (FK)
              └── Product_Record_ID (FK)
```

## Technologies

* MySQL
* SQL
* Relational Database Design
* Window Functions
* Primary & Foreign Keys
* Temporary Tables
* Data Normalization

## Key Takeaway

The project demonstrates how a **raw, wide inventory dataset can be transformed into a structured relational database** by identifying logical entities and separating transactional, pricing, and contextual information.

The resulting schema provides a cleaner foundation for querying inventory trends, analyzing demand, studying pricing effects, and incorporating factors such as weather, seasonality, and promotions into inventory forecasting analysis.

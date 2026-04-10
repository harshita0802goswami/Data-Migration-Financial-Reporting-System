# Data Migration & Finance Analytics - SQL

## Problem Statement  
AtliQ Hardware, a B2B manufacturer and distributor of computer peripherals, operated across multiple global markets but stored all operational data in Excel files — product sales, customer records, market data, and financial transactions. As business volumes scaled, Excel became the bottleneck: files crashed, reports took hours to refresh, and leadership had no reliable, real-time view of financial performance.

## Project Overiew
This project addresses the problem in two phases:
- Phase 1 Migrated all Excel data into a structured MySQL relational database.
- Phase 2 Built a suite of automated finance analytics reports — replacing every manual Excel process with reusable, parameterised SQL artifacts.

## Key Workstreams
- Track profitability and revenue trends by market
- Automate recurring business reporting
- Built monthly product-level sales reports for Croma India
- Developed customer-level gross sales tracking using stored procedures
- Designed market segmentation logic (Gold vs Silver) based on sales thresholds
- Created Top N analysis for markets, products, and customers by net sales
- Generated regional performance breakdowns and contribution % analysis
- Identified top 2 performing markets per region using ranking functions

## Concepts Used 
- Stored Procedures
- User Defined Functions (UDFs)
- Views for modular reporting
- Window Functions (DENSE_RANK, RANK, ROW_NUMBER, OVER())
- Query Optimization Techniques

##  Impact
- Reduced query runtime by ~78% (13s → 2.8s) by eliminating redundant UDF calls and introducing an optimized date dimension table.
- Enabled faster and scalable financial reporting
- Improved decision-making for market and product strategy
- Built a reusable SQL framework for Top-N and segmentation analysis
  

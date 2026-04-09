/** Generate a report of Individual product sales aggregated on a monthly basis at the 
product code level for 'Croma India' customer for FY 2021 to track individual product sales and run further product analytics. 
**/
 -- 90002002 - croma india
USE gdb0041;

SELECT * FROM dim_customer
WHERE customer = 'Croma';

SELECT * FROM fact_sales_monthly 
WHERE customer_code = '90002002'
AND fiscal_year = '2021';

SELECT 
	s.date, p.product_code, p.variant, s.sold_quantity, g.gross_price,
   ROUND(g.gross_price * s.sold_quantity,2) AS total_gross_price
FROM fact_sales_monthly s 
JOIN dim_product p 
ON 
	p.product_code = s.product_code
JOIN fact_gross_price g
ON 
	g.product_code = p.product_code AND
    g.fiscal_year = get_fiscal_year(s.date)
WHERE 
	customer_code = '90002002' AND
    get_fiscal_year(date) = 2021 AND
    get_quarter(date) = "Q2"
ORDER BY date DESC;

/** 
Task 2 : Generate an aggregated monthly gross sales report for Croma India Customer 
to track how much sales this particular customer is generating for the company and manage relationships accordingly
**/
SELECT 
	s.date, SUM(ROUND(g.gross_price * s.sold_quantity,2)) AS total_gross_price
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON 
	s.product_code = g.product_code AND
    g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = '90002002'
GROUP BY s.date
ORDER BY s.date ASC;


/** Task 2 : Generate an aggregated yearly gross sales report for Croma India Customer 
to track how much sales this particular customer is generating for the company and manage relationships accordingly
**/
SELECT 
	get_fiscal_year(s.date), SUM(ROUND(g.gross_price * s.sold_quantity,2)) AS total_gross_price
FROM fact_sales_monthly s
JOIN fact_gross_price g
ON 
	s.product_code = g.product_code AND
    g.fiscal_year = get_fiscal_year(s.date)
WHERE customer_code = '90002002'
GROUP BY get_fiscal_year(s.date);

/** Task 3 : Create a stored procedure that can determine the market badge based 
on if total sold quantity > 5 Million that market is considered Gold  else it is Silver
**/
SELECT 
	DISTINCT(c.customer_code), c.market, SUM(s.sold_quantity) as total_sold_quantity, 
    CASE 
		WHEN  SUM(s.sold_quantity) > 5000000 THEN "Gold"
        ELSE "Silver"
	END AS market_badge
FROM dim_customer c 
JOIN fact_sales_monthly s
ON 
	s.customer_code = c.customer_code

GROUP BY c.market ,c.customer_code;


/** Task 4 : Generate a full report on top markets, products, customers by net sales for a given transaction year
 so as to take appropriate actions to address any potential issues. **/
EXPLAIN ANALYZE
SELECT 
	s.date, p.product_code, p.variant, s.sold_quantity, g.gross_price,
   ROUND(g.gross_price * s.sold_quantity,2) AS total_gross_price, 
   pre.pre_invoice_discount_pct
FROM fact_sales_monthly s 
JOIN dim_product p 
ON 
	p.product_code = s.product_code
JOIN fact_gross_price g
ON 
	g.product_code = p.product_code AND
    g.fiscal_year = s.fiscal_year
   
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code = s.customer_code AND
	pre.fiscal_year = s.fiscal_year
WHERE 
    s.fiscal_year = 2021
ORDER BY date DESC
LIMIT 100000;

-- Post invoice deductions
WITH cte1 AS (SELECT 
	s.date, p.product_code, p.variant, s.sold_quantity, g.gross_price,
   ROUND(g.gross_price * s.sold_quantity,2) AS total_gross_price, 
   pre.pre_invoice_discount_pct
FROM fact_sales_monthly s 
JOIN dim_product p 
ON 
	p.product_code = s.product_code
JOIN fact_gross_price g
ON 
	g.product_code = p.product_code AND
    g.fiscal_year = s.fiscal_year
   
JOIN fact_pre_invoice_deductions pre
ON 
	pre.customer_code = s.customer_code AND
	pre.fiscal_year = s.fiscal_year
WHERE 
    s.fiscal_year = 2021
ORDER BY date DESC)
	select * , 
    (total_gross_price - total_gross_price * pre_invoice_discount_pct) AS net_invoice_sales
    from cte1;

-- AFTER VIEWS

SELECT *, 
	(gross_price_total - gross_price_total * pre_invoice_discount_pct) AS net_invoice_sales, 
    (post.discounts_pct + post.other_deductions_pct) AS post_invoice_discount_pct
    
 FROM sales_pre_invoice_discount s
 JOIN fact_post_invoice_deductions post
 ON 
    post.product_code = s.product_code AND
	post.customer_code = s.customer_code AND
    post.date = s.date;
	

SELECT * , 
ROUND((1- post_invoice_discount_pct)*net_invoice_sales,2) AS net_sales
FROM sales_postinv_discount po;

--  Top Markets
SELECT 
    	    c.customer, 
            round(sum(s.net_sales)/1000000,2) as net_sales_mln
	FROM gdb0041.net_sales s 
    JOIN dim_customer c
    ON 
		s.customer_code = c.customer_code
	where fiscal_year=2021
	group by c.customer
	order by net_sales_mln desc
	limit 5;
    
-- Top Customers
SELECT 
    	    customer, 
            round(sum(net_sales)/1000000,2) as net_sales_mln
            
	FROM gdb0041.net_sales
    
	where fiscal_year=2021
	group by market
	order by net_sales_mln desc
	limit 5;
    
# Top market by net sales %
with cte1 as (
		select 
                    customer, 
                    round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                    on s.customer_code=c.customer_code
        	where s.fiscal_year=2021
        	group by customer)
	select 
            *,
            net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
	from cte1
	order by net_sales_mln desc;

# Top 2 expenses in each category 
WITH cte1 AS (
    SELECT
        c.market,
        c.region,
        ROUND(SUM(gross_price_total)/1000000, 2) AS gross_sales_mln
    FROM gross_sales s
    JOIN dim_customer c
        ON c.customer_code = s.customer_code
    WHERE fiscal_year = 2021
    GROUP BY c.market, c.region 
),
cte2 AS (
    SELECT *,
        DENSE_RANK() OVER (
            PARTITION BY region 
            ORDER BY gross_sales_mln DESC
        ) AS drnk
    FROM cte1
)

SELECT * 
FROM cte2 
WHERE drnk <= 2;

		
        
        
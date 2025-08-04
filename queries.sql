use sql_project;

-- List all companies along with their sectors and industry types.

SELECT 
    name, sector
FROM
    companies;


-- Find the stock prices of ‘Infosys’ for the month of August 2025.

SELECT 
    c.company_id,
    c.name,
    c.sector,
    p.trade_date,
    p.open_price,
    p.close_price
FROM companies AS c
JOIN prices AS p ON c.company_id = p.company_id
WHERE c.name = 'Infosys'
  AND p.trade_date BETWEEN '2025-08-01' AND '2025-08-31'; 
  
  -- Retrieve the top 10 companies with the highest closing price on any date

  SELECT 
    c.company_id,
    c.name,
    c.sector,
    p.trade_date,
    p.open_price,
    p.close_price
FROM companies AS c
JOIN prices AS p ON c.company_id = p.company_id
where  p.trade_date = '2025-08-01'
order by p.close_price desc
limit 10;

-- Which companies belong to the ‘Pharmaceuticals’ sector

select * from companies
where sector = "Pharma";

-- Create View as we are combing 2 table frequently

CREATE VIEW combine_data AS
    SELECT 
        c.company_id,
        c.name,
        c.sector,
        p.trade_date,
        p.open_price,
        p.close_price
    FROM
        companies AS c
            JOIN
        prices AS p ON c.company_id = p.company_id;
        
        select * from combine_data;
 

-- Find the average closing price of each company.

SELECT 
    name, 
    sector, 
    round(AVG(close_price),2) AS avg_close_price
FROM 
    combine_data
GROUP BY 
    name, sector;
    
-- Which company has the highest number of dividend payouts?
    

select company_id, name, sector, count(dividend_per_share) as dividend_payouts 
from
(select 
c.company_id,
c.name,
c.sector,
d.dividend_per_share
from companies as c join dividends as d
on c.company_id = d.company_id) as cd
group by company_id, name, sector
order by dividend_payouts desc
limit 1;

-- Find companies where the difference between opening and closing price is greater than ₹30 on any trading day

SELECT 
    *, 
    abs(ROUND((close_price - open_price), 2)) AS price_change 
FROM 
    combine_data
WHERE 
    (close_price - open_price) >= 30 and trade_date = '2025-08-03'
    order by (close_price - open_price) desc;
    
    
-- List all companies that have never issued a dividend

SELECT *
FROM (
    SELECT 
        c.company_id,
        c.name,
        c.sector,
        COUNT(d.dividend_per_share) AS dividend_payouts
    FROM 
        companies AS c
    LEFT JOIN 
        dividends AS d ON c.company_id = d.company_id
    GROUP BY 
        c.company_id, c.name, c.sector
) AS cd
WHERE dividend_payouts = 0;


#### NOTE ####
#Below mentioned query are solved and understood with the help of external support.



-- Identify companies whose stock price decreased continuously for three consecutive days

SELECT company_id, name,close_price,prev_day_1,prev_day_2
FROM (
    SELECT 
        c.company_id,
        c.name,
        p.trade_date,
        p.close_price,
        LAG(p.close_price, 1) OVER (PARTITION BY p.company_id ORDER BY p.trade_date) AS prev_day_1,
        LAG(p.close_price, 2) OVER (PARTITION BY p.company_id ORDER BY p.trade_date) AS prev_day_2,
        LAG(p.close_price, 3) OVER (PARTITION BY p.company_id ORDER BY p.trade_date) AS prev_day_3
    FROM prices p
    JOIN companies c ON c.company_id = p.company_id
) AS sub
WHERE close_price < prev_day_1 AND prev_day_1 < prev_day_2;


-- Rank companies within each sector based on their average closing price

SELECT 
    company_id,
    name,
    sector,
    avg_close_price,
    RANK() OVER (PARTITION BY sector ORDER BY avg_close_price DESC) AS price_rank
FROM (
    SELECT 
        company_id,
        name,
        sector,
        AVG(close_price) AS avg_close_price
    FROM combine_data
    GROUP BY company_id, name, sector
) AS ranked_data;

-- Create a 5-day moving average of closing prices for each company


SELECT 
    company_id,
    name,
    trade_date,
    close_price,
    ROUND(AVG(close_price) OVER (
        PARTITION BY company_id 
        ORDER BY trade_date 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_5_day
FROM combine_data;


-- Find the top 3 most volatile stocks in terms of standard deviation of closing prices

SELECT 
    company_id,
    name,
    STDDEV(close_price) AS std_deviation
FROM 
    combine_data
GROUP BY 
    company_id, name
ORDER BY 
    std_deviation DESC
LIMIT 3;







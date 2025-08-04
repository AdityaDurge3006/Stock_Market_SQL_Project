 show create table companies;
 
CREATE TABLE `companies` (
  `company_id` int DEFAULT NULL,
  `name` text,
  `sector` text
);

show create table prices;

CREATE TABLE `prices` (
  `company_id` int DEFAULT NULL,
  `trade_date` text,
  `open_price` double DEFAULT NULL,
  `close_price` double DEFAULT NULL,
  `volume` int DEFAULT NULL
);

show create table dividends;

CREATE TABLE `dividends` (
  `company_id` int DEFAULT NULL,
  `year` int DEFAULT NULL,
  `dividend_per_share` double DEFAULT NULL
) ;


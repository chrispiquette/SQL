## Cohort Analysis (purchases by the cohort "country" over time)
## Note - most of the below logic is based on a tutorial from Chartio: https://chartio.com/resources/tutorials/performing-cohort-analysis-using-mysql/
## I adapted this logic to dummy data I configured based off of 'classicmodels' MySQL data - see here: http://www.mysqltutorial.org/mysql-sample-database.aspx                             

#product data exploration
SELECT * FROM
products LIMIT 5;
    
SELECT distinct productLine
FROM products ;
	
/*Classic Cars
Motorcycles
Planes
Ships
Trains
Trucks and Buses
Vintage Cars*/        

## 1. select first order date by customer (since there's no registration date column)
SELECT a.orderDate as first_order_date,
       a.customerNumber
FROM orders a
INNER JOIN (
	    SELECT customerNumber,
	    MIN(orderDate) as min_orderDate                  
	    FROM orders
	    GROUP BY 1
	    ) b
  ON a.customerNumber = b.customerNumber
 AND a.orderDate = b.min_orderDate;
                    
                    /*) */            
## 2. Select data we need from each table: order_id, order_date, customer_id, first_order_date (first purchase), and country (cohort)
SELECT
	a.orderNumber AS 'Order_ID',
	LEFT(a.orderDate,7) AS 'Order_Date',
	b.customerNumber AS 'Customer_ID',
	LEFT(c.First_Order_Date,7) as 'First_Order_Date',
	b.country AS 'Country'
FROM orders a
INNER JOIN customers b 
ON a.customerNumber = b.customerNumber
INNER JOIN (
		SELECT a.orderDate as First_Order_Date,
		       a.customerNumber
		FROM orders a
		INNER JOIN (
					  SELECT customerNumber,
					  MIN(orderDate) as min_orderDate                  
					  FROM orders
					  GROUP BY 1
				    ) b
		ON a.customerNumber = b.customerNumber
		AND a.orderDate = b.min_orderDate
	    ) c 
ON a.customerNumber = c.customerNumber ;
                            
## 3. Find out how long it takes a user to order again after their first order              
SELECT
	a.orderNumber AS 'Order_ID',
	a.orderDate AS 'Order_Date',
	b.customerNumber AS 'Customer_ID',
	c.First_Order_Date as 'First_Order_Date',
	PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m')) as 'Difference_in_Months',
	b.country AS 'Country'
FROM orders a
INNER JOIN customers b 
ON a.customerNumber = b.customerNumber
INNER JOIN (
	    SELECT a.orderDate as First_Order_Date,
	           a.customerNumber
	    FROM orders a
	    INNER JOIN (
			SELECT customerNumber,
			MIN(orderDate) as min_orderDate                  
			FROM orders
			GROUP BY 1
			) b
	    ON a.customerNumber = b.customerNumber
	    AND a.orderDate = b.min_orderDate
	   ) c 
ON a.customerNumber = c.customerNumber
WHERE PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m')) != 0
ORDER BY 4 ASC;          

### test select (can remove)
SELECT
	a.orderNumber AS 'Order_ID',
	a.orderDate AS 'Order_Date',
	b.customerNumber AS 'Customer_ID',
	c.First_Order_Date as 'First_Order_Date',
	AVG(PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m'))) as 'AVG_Difference_in_Months',
	b.country AS 'Country'
FROM orders a
INNER JOIN customers b 
ON a.customerNumber = b.customerNumber
INNER JOIN (
	     SELECT a.orderDate as First_Order_Date,
	 	    a.customerNumber
	     FROM orders a
	     INNER JOIN (
			 SELECT customerNumber,
			 MIN(orderDate) as min_orderDate                  
			 FROM orders
			 GROUP BY 1
		       ) b
       	     ON a.customerNumber = b.customerNumber
	     AND a.orderDate = b.min_orderDate
	    ) c 
ON a.customerNumber = c.customerNumber
WHERE PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m')) != 0
GROUP BY 1,2,3,4,6
ORDER BY 4,6 ASC;          
                            
## 4. Let's trim the above data - this gives us the average difference in time from first order to next orders and total orders, both by country
## This gives us the final output for visualization.

SELECT
      AVG(PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m'))) as 'AVG_Difference_in_Months',
      b.country AS 'Country',
      COUNT(DISTINCT a.orderNumber) AS 'Order_Count'
FROM orders a
INNER JOIN customers b 
ON a.customerNumber = b.customerNumber
INNER JOIN (
	    SELECT a.orderDate as First_Order_Date,
	           a.customerNumber
	    FROM orders a
	    INNER JOIN (
			SELECT customerNumber,
			MIN(orderDate) as min_orderDate                  
			FROM orders
			GROUP BY 1
	       	      ) b
	    ON a.customerNumber = b.customerNumber
	    AND a.orderDate = b.min_orderDate
	   ) c 
ON a.customerNumber = c.customerNumber 
WHERE PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m')) != 0
GROUP BY 2
ORDER BY 3 DESC
;          
12.6267	USA	75
17.1290	Spain	31
11.9600	France	25
12.9286	Australia	14
14.0909	New Zealand	11
12.2500	UK	8
10.7143	Singapore	7
12.6667	Finland	6
10.1667	Italy	6
14.4000	Norway	5
15.4000	Austria	5
17.6000	Sweden	5
12.8000	Belgium	5
17.8000	Denmark	5
14.0000	Germany	4
9.7500	Canada	4
6.2500	Japan	4
14.0000	Philippines	2
1.0000	Hong Kong	1
7.0000	Ireland	1
6.0000	Switzerland	1                    

/* QA to check counts of orders by country*/
SELECT
      PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m'))  as 'Difference_in_Months',
      DATE_FORMAT(a.orderDate, '%Y%m') as orderDate,
      DATE_FORMAT(c.First_Order_Date, '%Y%m') as first_orderDate,
      b.country AS 'Country'
FROM orders a
INNER JOIN customers b 
ON a.customerNumber = b.customerNumber
INNER JOIN (
            SELECT a.orderDate as First_Order_Date,
                   a.customerNumber
	    FROM orders a
            INNER JOIN (
			SELECT customerNumber,
			MIN(orderDate) as min_orderDate                  
			FROM orders
			GROUP BY 1
			) b
		ON a.customerNumber = b.customerNumber
		AND a.orderDate = b.min_orderDate
           ) c 
ON a.customerNumber = c.customerNumber 
WHERE PERIOD_DIFF(DATE_FORMAT(a.orderDate, '%Y%m'), DATE_FORMAT(c.First_Order_Date, '%Y%m')) != 0
ORDER BY 4 DESC
;       

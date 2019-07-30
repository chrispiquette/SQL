/* This table joins raw ad bid request data with raw ad bid response data by a particular campaign */
/* This is useful for analyzing how an ad is delivering in programmatic ad-buying environments */

/* Needs CID update for both sides of JOIN */
SELECT time_dimension as Date_Hour,
       campaign_id as CID,            
            /*b.Bid_Requests,*/
            b.CID_Bid_Requests,
            SUM(CASE WHEN event_type = 17 THEN 1 ELSE 0 END) as Bid_Responses,
            CAST(ROUND(SAFE_DIVIDE(SUM(CASE WHEN event_type = 17 THEN 1 ELSE 0 END), CID_Bid_Requests), 5) as numeric) as BidRes_divby_BidReq, 
            SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) as Impressions,
            ROUND(SAFE_DIVIDE(SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END), SUM(CASE WHEN event_type = 17 THEN 1 ELSE 0 END)), 2) as ImpDivByBidResponse,           
            SUM(CASE WHEN event_type = 14 THEN 1 ELSE 0 END) as Clicks
                FROM `database.bid_response_table` a
                
                JOIN (
                      SELECT  time_dimension as Date_Hour,
                      SUM(CASE WHEN event_type = 15 THEN 1 ELSE 0 END) as Bid_Requests,
                      SUM(CASE WHEN event_type = 15 AND field_3 like "%3969%" OR field_4 like "%3969%" OR field_5 like "%3969%" THEN 1 END) as CID_Bid_Requests
                          FROM `database.bid_request_table`
                            WHERE _PARTITIONTIME >= TIMESTAMP("2019-07-04")
                            /*WHERE time_dimension = 2019070723 */
                              GROUP BY 1
                              ORDER BY 1 DESC
                        ) b
                      ON a.time_dimension = b.Date_Hour  
                          
                          WHERE _PARTITIONTIME >= TIMESTAMP("2019-07-04")
                          AND campaign_id in (3969)
                          GROUP BY 1,2,3
                          ORDER BY 1 DESC ;
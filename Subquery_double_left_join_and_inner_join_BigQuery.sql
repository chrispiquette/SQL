/* This query gets daily raw ad spend targets adjusted for margins and joins with actual spends, by various IDs */

SELECT a.Date,
       a.BID,
       a.CID,
       ROUND(SAFE_DIVIDE(c.Pre_margin_Spend, (1-b.margin_value)),0) as Client_Spend,
       ROUND(SAFE_DIVIDE(a.Pre_margin_Daily_Limit_End, (1-b.margin_value)),0) as Campaign_Setup_Daily_Limit_End, 
       ROUND((SAFE_DIVIDE(c.Pre_margin_Spend, (1-b.margin_value)) - SAFE_DIVIDE(a.Pre_margin_Daily_Limit_End, (1-b.margin_value)))
             /SAFE_DIVIDE(a.Pre_margin_Daily_Limit_End, (1-b.margin_value)),2) as Delivery_Var
       
               FROM (
                     SELECT t.pst_date as Date,
                            t.account_id as BID,
                            t.campaign_id as CID,
                            t.daily_limit as Pre_margin_Daily_Limit_End                           
                              FROM database.hourly_dimension_table t
                              JOIN (SELECT pst_date as Date,
                                            MAX(time_dimension) as max_hour
                                              FROM database.hourly_dimension_table tt
                                                 GROUP BY 1 
                                                  ) tt                
                                ON t.time_dimension=tt.max_hour                                             
                                  /*WHERE campaign_id in (3289) */
                                 /*   WHERE pst_date >= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -28 DAY) */
                                      /*GROUP BY 1,3,4,5 */
                                      ORDER BY 1 DESC
                                ) a                                    
                     LEFT JOIN 
                                (
                                SELECT campaign_id as CID,
                                   margin_value        
                                      FROM database.campaign_dimension_table
                                         /*WHERE campaign_id in (3289) */                                        
                                          ) b
                      ON a.CID=b.CID                 
                                       
                      LEFT JOIN 
                                (
                                SELECT 
                                   pst_date as Date,
                                   company_id as BID,
                                   campaign_id as CID, 
                                   sum(spend) as Pre_margin_Spend
                                      FROM database.daily_campaign_metrics_prod
                                         /* WHERE campaign_id in (3289)*/
                                          GROUP BY 1,2,3                                          
                                          ) c                  
                                                           
                      ON a.CID=c.CID
                      AND a.Date=c.Date
                        /*WHERE a.CID in (3289,3286,3289,3292,3293,3679,3828,4941,5546,5688) /**/ --Leesa*/
                        /*WHERE a.CID in (3292) */
                         WHERE a.CID  in (5773)
                          AND a.Date <= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -1 DAY) 
                          AND a.Date >= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -14 DAY)
                            /*AND Pre_margin_Spend >0*/
                            ORDER BY 1 DESC                           
                              ;   
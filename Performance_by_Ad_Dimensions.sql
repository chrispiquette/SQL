/** Goal:  To gather performance metrics by various ad dimensions for the last four weeks, with each row representing a weekly summary.
/* The data was from BigQuery and includes the option to include additional dimensions (ad type, campaign ID, etc).
/* Use “WHERE” and “AND” clauses to modify as needed. */
/* *I had some help on the nested current timestamp to "Date_Add" conversions, but the rest I wrote. */


SELECT /*account_id as BID, */
       /*company_name as Advertiser, */
       /*campaign_type_abbr as Funnel_Type, */
       /*ad_container_type_abbr as AdType,  */
       /*pst_date, */

        CASE WHEN pst_date >= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -7 DAY) 
             THEN DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -1 DAY)
            
             WHEN pst_date >= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -14 DAY) 
             THEN DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -8 DAY)

             WHEN pst_date >= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -21 DAY) 
             THEN DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -15 DAY)
            
             WHEN pst_date >= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -28 DAY) 
             THEN DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -21 DAY)

             ELSE pst_date END AS Week_End_Date,     

       ROUND(SUM(cost),0) AS Spend,
       /*SUM(impressions) AS Impressions, */
       SUM(v_impressions) AS Impressions,
       /* SUM(clicks) AS Clicks,  */
       SUM(v_clicks) AS Clicks,
       ROUND(SAFE_DIVIDE(sum(v_clicks), sum(v_impressions)), 4) as CTR,
       ROUND(SUM(ctc)) AS Click_Conv,
       ROUND(SUM(tc)) AS Total_Conv,
       ROUND(SAFE_DIVIDE(sum(ctc), sum(tc)), 2) as CTCdivbyConv,
       ROUND(SAFE_DIVIDE(sum(tc), sum(v_clicks)), 3) as Conv_divby_Clicks,
       /* ROUND(SAFE_DIVIDE(sum(tc_ov), sum(cost)), 1) as ROI,*/
       ROUND(SAFE_DIVIDE(sum(tc), sum(v_impressions)), 7)*10000 as Conv_divby_Imps,
       /* ROUND(SAFE_DIVIDE(sum(tc), sum(cost)), 4) as Conv_divby_Spend */
       /* SUM(tc) AS Conversions,
       SUM(tc_ov) AS Client_Revenue */
       ROUND(SAFE_DIVIDE(sum(cost), sum(tc))) as CPA,
       ROUND(SAFE_DIVIDE(sum(cost), sum(v_clicks)),2) as CPC
                  FROM database.table                
                        WHERE pst_date >= DATE_ADD((SELECT EXTRACT(DATE FROM CURRENT_TIMESTAMP() AT TIME ZONE 'America/Los_Angeles')), INTERVAL -28 DAY)
                        GROUP BY 1
                        ORDER BY 1 DESC; 


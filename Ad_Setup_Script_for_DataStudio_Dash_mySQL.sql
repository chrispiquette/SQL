/** Goal: Gather Type A and Type B Ad setup data from several tables, to union into one view.
/** This was used a source script for a Data Studio dashboard I built.

/* Ads type A - Part 1 of Union */
(SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(a.source, "/",-2),"/",1) as BID, 
       a.cid as Ad_Group_ID,
       b.name as Ad_Group,
          CASE WHEN a.cid in (SELECT id as cid FROM database.table_1 WHERE status = 1) THEN "Active"
               WHEN a.cid in (SELECT id as cid FROM database.table_1 WHERE status = 0) THEN "Inactive"
               ELSE "Unknown"
               END as Ad_Group_Status,
	     a.id as OnePortal_Ad_Id,
	     a.name as Ad, 
           CASE WHEN a.status = 1 THEN "Active"
                WHEN a.status = 2 THEN "Inactive"
	        WHEN a.status = 3 THEN "Rejected" 
                ELSE a.status 
                END AS Ad_Status,
       a.destination as Destination_URL,
       CONVERT_TZ(a.updated,'+00:00','-07:00') as updated
	   /*CAST(a.updated as DATE) as Updated_Date*/
			FROM database.table_2 a
            JOIN database.table_1 b
	      ON a.cid=b.id
		 WHERE DATE_SUB(CURDATE(),INTERVAL 90 DAY) <= a.updated
                /*AND a.source like '%2084%'*/
                )
UNION ALL              

/* Ads type B - Part 2 of Union */
(SELECT
       a.bid as BID, 
       b.cid as Ad_Group_ID,
       c.name as Ad_Group,
	  CASE WHEN b.cid in (SELECT id as cid FROM database.table_1 WHERE status = 1) THEN "Active"
	       WHEN b.cid in (SELECT id as cid FROM database.table_1 WHERE status = 0) THEN "Inactive"
               ELSE "Unknown"
               END as Ad_Group_Status,	
       b.id as OnePortal_Ad_ID, 
       a.name as Ad, 
	 CASE WHEN a.status = 1 THEN "Active"
		    WHEN a.status = 2 THEN "Inactive"
		    WHEN a.status = 3 THEN "Rejected"	
		    WHEN a.status = 0 THEN "Never_Activated"
		    WHEN a.status = 6 THEN "Deleted_from_UI"
		    WHEN a.status = 5 THEN "Unnamed_Ad"
		    ELSE a.status 
		    END AS Ad_Status,
       a.productURL as Destination_URL, 
       a.updated
       /*CAST(a.updated as DATE) as Updated_Date*/
    			FROM database.table_3 a
    			JOIN database.table_4 b
    				ON a.id=b.pid
          JOIN database.table_1 c
            ON b.cid=c.id
    	       WHERE DATE_SUB(CURDATE(),INTERVAL 90 DAY) <= a.updated						                           
                                )                            
                                ORDER BY 2 DESC ;

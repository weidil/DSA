SELECT x.dc_name_inner_short as '-', x.时间段, IFNULL(y.`2016-12-21`,0) AS '2016-12-21', IFNULL(y.`2016-12-22`,0) AS '2016-12-22', IFNULL(y.`2016-12-23`,0) AS '2016-12-23',
                                              IFNULL(y.`2016-12-24`,0) AS '2016-12-24', IFNULL(y.`2016-12-25`,0) AS '2016-12-25', IFNULL(y.`2016-12-26`,0) AS '2016-12-26',
                                              IFNULL(y.`2016-12-27`,0) AS '2016-12-27'
FROM  
     (SELECT *
			FROM

							 (SELECT DISTINCT id, dc_name_inner_short
							 FROM geo.dc_mapping) as a 

			CROSS JOIN 

							 (SELECT 
							 '00:00-04:00' as 时间段
							 UNION
							 SELECT
							 '04:00-08:00' AS 时间段
							 UNION
							 SELECT
							'08:00-12:00' AS 时间段
							 UNION
							 SELECT 
							'12:00-16:00'	AS 时间段
							 UNION
							 SELECT
							 '16:00-20:00' AS 时间段
							 UNION
							 SELECT
							 '20:00-24:00' AS 时间段) as b)  x

		 LEFT OUTER JOIN

		(SELECT test.id, test.dc_name_inner_short, (CASE WHEN test.time_period = 0 THEN '00:00-04:00'
																								WHEN test.time_period = 1 THEN '04:00-08:00'
																								WHEN test.time_period = 2 THEN	'08:00-12:00'
																								WHEN test.time_period = 3 THEN '12:00-16:00'
																								WHEN test.time_period = 4 THEN '16:00-20:00'
																								WHEN test.time_period = 5 THEN '20:00-24:00'
																								END) AS 时间段,
       SUM(test.`2016-12-21`) AS '2016-12-21', SUM(test.`2016-12-22`) AS '2016-12-22', SUM(test.`2016-12-23`) AS '2016-12-23',
			 SUM(test.`2016-12-24`) AS '2016-12-24', SUM(test.`2016-12-25`) AS '2016-12-25', SUM(test.`2016-12-26`) AS '2016-12-26',SUM(test.`2016-12-27`) AS '2016-12-27'
			FROM (SELECT d.id, d.dc_name_inner_short, 	c.time_period,	
							(CASE WHEN DATE(c.`日期`) = '2016-12-21' THEN c.告警总量 ELSE 0 END) AS '2016-12-21',
							(CASE WHEN DATE(c.`日期`) = '2016-12-22' THEN c.告警总量 ELSE 0 END) AS '2016-12-22',
							(CASE WHEN DATE(c.`日期`) = '2016-12-23' THEN c.告警总量 ELSE 0 END) AS '2016-12-23',
							(CASE WHEN DATE(c.`日期`) = '2016-12-24' THEN c.告警总量 ELSE 0 END) AS '2016-12-24',
							(CASE WHEN DATE(c.`日期`) = '2016-12-25' THEN c.告警总量 ELSE 0 END) AS '2016-12-25',
							(CASE WHEN DATE(c.`日期`) = '2016-12-26' THEN c.告警总量 ELSE 0 END) AS '2016-12-26',
							(CASE WHEN DATE(c.`日期`) = '2016-12-27' THEN c.告警总量 ELSE 0 END) AS '2016-12-27'
								FROM geo.dc_mapping d, (SELECT
				b.id AS id,
				FLOOR( HOUR ( a.break_time ) / 4 ) AS time_period,
				a.break_time AS 日期,
				COUNT(*) AS 告警总量
			FROM
				alarm_act a,
				geo.dc_mapping b 
			WHERE
				a.dc_id = b.id 
				AND DATE(a.break_time) >= '2016-12-21'
				AND DATE(a.break_time) <= '2016-12-27'
			GROUP BY
				b.id,
				DAY (a.break_time),
				FLOOR( HOUR ( a.break_time ) / 4 )) c
			WHERE d.id = c.id
			#GROUP BY d.id,c.`时间段`
			ORDER BY d.dc_name_inner_short ,c.time_period) test
			GROUP BY test.id, test.time_period
			ORDER BY test.dc_name_inner_short, test.time_period)y

ON    x.id = y.id AND x.时间段 = y.时间段 ;

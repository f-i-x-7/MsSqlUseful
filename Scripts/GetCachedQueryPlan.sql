--SELECT * FROM sys.dm_exec_cached_plans

SELECT ecp.usecounts, ecp.cacheobjtype, ecp.objtype, est.text, eqp.query_plan
FROM sys.dm_exec_cached_plans ecp
OUTER APPLY sys.dm_exec_sql_text(ecp.plan_handle) est
OUTER APPLY sys.dm_exec_plan_attributes(ecp.plan_handle) epa
OUTER APPLY sys.dm_exec_query_plan(ecp.plan_handle) eqp
WHERE 1=1
--AND est.text LIKE '%GetCustodyMarginCallList%'
--AND ecp.usecounts > 1
AND epa.attribute = 'objectid'
AND epa.value = OBJECT_ID('dbo.GetCustodyMarginCallList')
--ORDER BY ecp.usecounts DESC;
GO

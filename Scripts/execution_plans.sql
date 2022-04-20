SELECT CP.UseCounts, CP.Cacheobjtype, CP.Objtype, ST.[Text], QP.query_plan, CP.plan_handle
FROM sys.dm_exec_cached_plans CP
CROSS APPLY sys.dm_exec_sql_text(CP.plan_handle) ST
CROSS APPLY sys.dm_exec_query_plan(CP.plan_handle) QP
WHERE ST.[Text] LIKE '%RptCgmlEqm23Recon%'


--DBCC FREEPROCCACHE(0x050005001A6FF04CF08D9C330200000001000000000000000000000000000000000000000000000000000000)
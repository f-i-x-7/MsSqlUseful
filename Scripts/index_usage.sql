-- https://www.mssqltips.com/sqlservertip/1239/how-to-get-index-usage-information-in-sql-server/
-- http://www.databasejournal.com/features/mssql/importance-of-statistics-and-how-it-works-in-sql-server-part-1.html
-- http://www.databasejournal.com/features/mssql/importance-of-statistics-and-how-it-works-in-sql-server-part-2.html
SELECT
	SCHEMA_NAME(O.[schema_id]) AS [Schema Name],
	OBJECT_NAME(A.[object_id]) AS [Object Name],
	I.name AS [Index Name],
	A.leaf_insert_count,
	A.leaf_update_count,
	A.leaf_delete_count
FROM sys.dm_db_index_operational_stats(NULL,NULL,NULL,NULL ) A
INNER JOIN sys.indexes I ON I.[object_id] = A.[object_id] AND I.index_id = A.index_id
INNER JOIN sys.objects O ON A.[object_id] = O.[object_id]
WHERE OBJECTPROPERTY(A.[object_id], 'IsUserTable') = 1
AND A.database_id = DB_ID()
ORDER BY 1, 2, 3


SELECT
	SCHEMA_NAME(O.[schema_id]) AS [Schema Name],
	OBJECT_NAME(S.[object_id]) AS [Object Name],
	I.name AS [Index Name],
	S.user_seeks,
	S.user_scans,
	S.user_lookups,
	S.user_updates
FROM sys.dm_db_index_usage_stats S
INNER JOIN sys.indexes AS I ON I.[object_id] = S.[object_id] AND I.index_id = S.index_id
INNER JOIN sys.objects O ON S.[object_id] = O.[object_id]
WHERE OBJECTPROPERTY(S.[object_id], 'IsUserTable') = 1
AND S.database_id = DB_ID()
ORDER BY 1, 2, 3
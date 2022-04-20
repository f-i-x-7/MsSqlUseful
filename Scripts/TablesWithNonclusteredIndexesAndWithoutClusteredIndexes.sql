SELECT T.*
FROM
(
	SELECT
		SCHEMA_NAME(tbl.[schema_id]) AS [Schema name],
		OBJECT_NAME(tbl.[object_id]) AS [Table name]
	FROM sys.indexes i
	INNER JOIN sys.objects tbl ON i.[object_id] = tbl.[object_id]
	WHERE tbl.is_ms_shipped = 0
	AND i.index_id = 0 -- heap
	AND tbl.[type] = 'U' -- user table; this is required to ignore, for example, table-valued functions that can appear in results of this query
	AND EXISTS
	(
		SELECT TOP(1) 1
		FROM sys.indexes i1
		WHERE i1.[object_id] = i.[object_id]
		AND i1.index_id <> 0
	)
) T
WHERE T.[Schema name] NOT IN ('OFZ', 'SUP', 'OBS', 'MigRasTmp', 'MIGRATION') -- ignore non-production tables
AND NOT -- temp decision: ignore pend tables
(
	T.[Table name] LIKE 'PEND[_]%'
	OR
	T.[Table name] LIKE '%PEND'
)
AND NOT -- ignore HOPS tables
(
	T.[Schema name] = 'MDM'
	OR
	T.[Schema name] = 'dbo'
	AND
	(
		T.[Table name] LIKE 'file[_]%'
		OR
		T.[Table name] LIKE 'sys[_]%'
		OR
		T.[Table name] LIKE 'tbl[_]%'
	)
)
ORDER BY
	T.[Schema name],
	T.[Table name]
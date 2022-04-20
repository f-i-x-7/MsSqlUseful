SELECT T.*
FROM
(
	SELECT
		SCHEMA_NAME(tbl.[schema_id]) AS [Schema name],
		OBJECT_NAME(tbl.[object_id]) AS [Table name],
		c.name AS [Column name]
	FROM sys.objects tbl
	INNER JOIN sys.columns c ON tbl.[object_id] = c.[object_id]
	INNER JOIN sys.types t ON c.system_type_id = t.system_type_id
	WHERE tbl.is_ms_shipped = 0
	AND tbl.[type] = 'U' -- user table; this is required to ignore, for example, table-valued functions or views that can appear in results of this query
	AND c.is_nullable = 1
	AND c.is_computed = 0 -- temp decision: ignore computed columns (it seems that their nullability cannot be changed)
	AND t.name = 'bit'
) T
WHERE T.[Schema name] NOT IN (N'OFZ', N'SUP', N'SSAPI', N'MIGRATION', N'MigRasTmp', N'OBS', N'TAX2DATACHANGE', N'EUC') -- ignore non-production tables and OFZ
AND NOT -- temp decision: ignore pend tables
(
	T.[Table name] LIKE 'PEND[_]%'
	OR
	T.[Table name] LIKE '%[_]PEND'
)
AND T.[Table name] NOT LIKE 'sobos[_]%' -- ignore dummy tables for FIS synonyms
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
	T.[Table name],
	T.[Column name]
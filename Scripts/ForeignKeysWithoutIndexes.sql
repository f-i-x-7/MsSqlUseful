SELECT T.*
FROM
(
	SELECT
		SCHEMA_NAME(tbl.[schema_id]) AS [Schema name],
		OBJECT_NAME(fkc.parent_object_id) AS [Table name],
		ac.name AS [Column name]
	FROM sys.foreign_key_columns fkc
	INNER JOIN sys.all_columns ac ON fkc.parent_column_id = ac.column_id AND fkc.parent_object_id = ac.[object_id]
	INNER JOIN sys.objects tbl ON ac.[object_id] = tbl.[object_id]
	WHERE tbl.is_ms_shipped = 0

	EXCEPT

	SELECT
		SCHEMA_NAME(tbl.[schema_id]),
		OBJECT_NAME(ic.[object_id]),
		ac.name
	FROM sys.index_columns ic
	INNER JOIN sys.all_columns ac ON ic.[object_id] = ac.[object_id] AND ic.column_id = ac.column_id
	INNER JOIN sys.objects tbl ON ic.[object_id] = tbl.[object_id]
	WHERE ic.key_ordinal = 1
	AND tbl.is_ms_shipped = 0
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
	[Schema name],
	[Table name],
	[Column name]
GO
SELECT
	s.Name AS SchemaName,
	t.NAME AS TableName,
	p.[Rows] AS RowCounts,

	SUM(a.total_pages) * 8 AS TotalSpaceKB,
	SUM(a.used_pages) * 8 AS UsedSpaceKB,
	(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB,

	CAST(SUM(a.total_pages) * 8 AS DECIMAL(38, 8)) / 1024 / 1024 AS TotalSpaceGB,
	CAST(SUM(a.used_pages) * 8 AS DECIMAL(38, 8)) / 1024 / 1024 AS UsedSpaceGB,
	CAST((SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS DECIMAL(38, 8)) / 1024 / 1024 AS UnusedSpaceGB
FROM
	sys.tables t
INNER JOIN
	sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN
	sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN
	sys.allocation_units a ON p.partition_id = a.container_id
LEFT OUTER JOIN
	sys.schemas s ON t.schema_id = s.schema_id
WHERE
	t.NAME NOT LIKE 'dt%'
	AND t.is_ms_shipped = 0
	AND i.OBJECT_ID > 255
GROUP BY
	t.Name, s.Name, p.[Rows]
ORDER BY
	UsedSpaceKB desc
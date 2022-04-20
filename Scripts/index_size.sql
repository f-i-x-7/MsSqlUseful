SELECT
	SCHEMA_NAME(o.schema_id) AS SchemaName,
	OBJECT_NAME(i.OBJECT_ID) AS TableName,
	i.name AS IndexName,
	i.index_id AS IndexID,
	8 * SUM(a.used_pages) AS [Index Size (KB)],
	8.0 * SUM(a.used_pages) / 1024 AS [Index Size (MB)],
	8.0 * SUM(a.used_pages) / 1024 / 1024 AS [Index Size (GB)]
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
JOIN sys.objects AS o ON i.object_id = o.object_id
GROUP BY o.schema_id, i.OBJECT_ID, i.index_id, i.name
ORDER BY SchemaName, TableName, [Index Size (KB)] DESC
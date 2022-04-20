DECLARE @TableSchemaName SYSNAME = N'dbo',
		@TableName SYSNAME = N'TAX_OPERATION';

DECLARE @FullObjectName NVARCHAR(1000) = QUOTENAME(ISNULL(@TableSchemaName, N'dbo')) + N'.' + QUOTENAME(@TableName);

-- old, with distinct in final select
/*SELECT DISTINCT
	SCHEMA_NAME(O.[schema_id]) AS SchemaName,
	o.name AS ObjectName,
	o.type_desc AS ObjectType
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.[object_id] = o.[object_id]
INNER JOIN sys.sql_dependencies dep ON m.[object_id] = dep.[object_id]
INNER JOIN sys.tables tab ON tab.[object_id] = dep.referenced_major_id
WHERE tab.name = @TableName
AND tab.[schema_id] = SCHEMA_ID(@TableSchemaName)
AND dep.is_updated = 1
ORDER BY
	SchemaName,
	ObjectName;*/

-- new, with distinct in inner query
/*SELECT
	SCHEMA_NAME(O.[schema_id]) AS SchemaName,
	o.name AS ObjectName,
	o.type_desc AS ObjectType
FROM sys.sql_modules m
INNER JOIN sys.objects o ON m.[object_id] = o.[object_id]
CROSS APPLY
(
	SELECT DISTINCT dep1.referenced_major_id
	FROM sys.sql_dependencies dep1
	WHERE dep1.[object_id] = m.[object_id]
	AND dep1.is_updated = 1
) dep
INNER JOIN sys.tables tab ON tab.[object_id] = dep.referenced_major_id
WHERE tab.name = @TableName
AND tab.[schema_id] = SCHEMA_ID(@TableSchemaName)
ORDER BY
	SchemaName,
	ObjectName;*/

-- new2
SELECT
	T.ReferencingObjectName,
	o.type_desc AS ReferencingObjectType
FROM sys.dm_sql_referencing_entities(@FullObjectName, N'object') refing -- 'refing': get all objects that have references to specified table, with short information about reference
CROSS APPLY
(
	SELECT
		QUOTENAME(refing.referencing_schema_name) + N'.' + QUOTENAME(refing.referencing_entity_name) AS ReferencingObjectName
) T
CROSS APPLY sys.dm_sql_referenced_entities(T.ReferencingObjectName, N'object') refed -- 'refed': get all objects referenced by object from 'refing' and select detailed reference information
INNER JOIN sys.objects o ON refing.referencing_id = o.[object_id]
WHERE refed.referenced_schema_name = @TableSchemaName -- filter 'refed' to show detailed reference information only by specified table
AND refed.referenced_entity_name = @TableName
AND refed.referenced_minor_name IS NULL -- we do not seek for column references here, so perform such filtering
AND refed.is_updated = 1 -- ensure that it is not SELECT statement reference
AND refing.referencing_schema_name NOT IN (N'SUP', N'SSAPI', N'MIGRATION', N'MigRasTmp', N'OBS', N'TAX2DATACHANGE', N'EUC') -- ignore objects from non-production schemas
AND o.[type] IN
(
	-- procedures (including CLR)
	'P', 'PC', 'X',
	-- functions (including CLR)
	'FN', 'IF', 'TF', 'FS', 'FT',
	-- triggers (including CLR)
	'TA', 'TR',
	-- views
	'V'
)
ORDER BY
	T.ReferencingObjectName,
	ReferencingObjectType;
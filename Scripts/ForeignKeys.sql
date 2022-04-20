DECLARE @parentTable NVARCHAR(100) = N'dbo.DAILY'

DECLARE @isForAllTables BIT = CASE
		WHEN ISNULL(LTRIM(RTRIM(@parentTable)), N'') = N'' THEN 1
		ELSE 0
	END

DECLARE @tableObjectId INT

IF @isForAllTables = 0
BEGIN
	SET @tableObjectId = OBJECT_ID(@parentTable)

	IF @tableObjectId IS NULL
		THROW 50000, 'Such table does not exist.', 1
END

SELECT
	SCHEMA_NAME(FK.[schema_id]) as ChildTableSchema,
	OBJECT_NAME(FK.parent_object_id) as ChildTable,
	CC.name as ChildColumn,
	SCHEMA_NAME(PT.[schema_id]) as ParentTableSchema,
	OBJECT_NAME(PT.[object_id]) as ParentTable,
	PC.name as ParentColumn,

	'FROM ' + SCHEMA_NAME(FK.[schema_id]) + '.' + OBJECT_NAME(FK.parent_object_id) +
		' t1' + CHAR(13) + 'INNER JOIN ' + SCHEMA_NAME(PT.[schema_id]) + '.' + OBJECT_NAME(PT.[object_id]) + ' t2 ON ' +
		't1.' + CC.name + ' = t2.' + PC.name as JoinStatement,

	'ALTER TABLE ' + SCHEMA_NAME(FK.[schema_id]) + '.' + OBJECT_NAME(FK.parent_object_id) + ' DROP CONSTRAINT ' + OBJECT_NAME(FK.[object_id]) as DropConstraintStatement,

	*
FROM sys.foreign_keys FK
INNER JOIN sys.foreign_key_columns FKC ON FK.[object_id] = FKC.constraint_object_id
INNER JOIN sys.columns CC ON FK.parent_object_id = CC.[object_id] and FKC.parent_column_id = CC.column_id
INNER JOIN sys.columns PC ON FK.referenced_object_id = PC.[object_id] and FKC.referenced_column_id = PC.column_id
INNER JOIN sys.tables PT ON FK.referenced_object_id = PT.[object_id]
WHERE
(
	PT.[object_id] = @tableObjectId
	or
	@isForAllTables = 1
)
ORDER BY
	ChildTableSchema,
	ChildTable,
	ChildColumn
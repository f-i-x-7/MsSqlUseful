SET NOCOUNT ON
GO

DECLARE @schemaName SYSNAME = 'SUP',
		-- for cursor
		@tableName SYSNAME,
		@sqlStatement NVARCHAR(MAX)

DECLARE @Tables TABLE
(
	TableName SYSNAME
)

INSERT @Tables(TableName)
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
AND TABLE_SCHEMA = @schemaName

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
SELECT TableName
FROM @Tables

OPEN cur

WHILE 1=1
BEGIN
	FETCH cur INTO @tableName

	IF @@FETCH_STATUS <> 0 BREAK

	SET @sqlStatement = NULL
	SET @sqlStatement = 'TRUNCATE TABLE [' + @schemaName + '].[' + @tableName + ']'

	PRINT @sqlStatement
	EXEC(@sqlStatement)
END

CLOSE cur
DEALLOCATE cur
GO

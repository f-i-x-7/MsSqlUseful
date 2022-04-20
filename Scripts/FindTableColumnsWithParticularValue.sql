DECLARE @tableSchema SYSNAME,
		@tableName SYSNAME,
		@columnName SYSNAME,
		@sqlStatement NVARCHAR(MAX)

DECLARE charCur CURSOR LOCAL FAST_FORWARD FOR
SELECT C.TABLE_SCHEMA, C.TABLE_NAME, C.COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS C
INNER JOIN sys.tables T ON C.TABLE_NAME = T.name AND SCHEMA_ID(C.TABLE_SCHEMA) = T.[schema_id] -- exclude views
WHERE C.DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar')
AND C.TABLE_SCHEMA NOT IN (N'SUP', N'SSAPI', N'MIGRATION', N'MigRasTmp', N'OBS', N'TAX2DATACHANGE', N'EUC') -- show only production code tables
ORDER BY C.TABLE_SCHEMA, C.TABLE_NAME, C.COLUMN_NAME

OPEN charCur

WHILE 1=1
BEGIN
	FETCH charCur INTO @tableSchema, @tableName, @columnName

	IF @@FETCH_STATUS != 0 BREAK

	SET @sqlStatement = ''

	SET @sqlStatement = '
	IF EXISTS (SELECT 1 FROM [' + @tableSchema + '].[' + @tableName + '] WHERE [' + @columnName + '] IN (''Brokerage'', ''Agent''))
	BEGIN
		PRINT ''[' + @tableSchema + '].[' + @tableName + '].[' + @columnName + ']''
	END'

	--PRINT @sqlStatement

	EXEC(@sqlStatement)
END

CLOSE charCur
DEALLOCATE charCur
GO

DECLARE @name SYSNAME,
		@statement NVARCHAR(256)

DECLARE tablesCur CURSOR LOCAL FAST_FORWARD FOR
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'dbo'
AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME

OPEN tablesCur

WHILE 1=1
BEGIN
	FETCH tablesCur INTO @name

	IF @@FETCH_STATUS <> 0 BREAK

	SET @statement = 'IF EXISTS (SELECT TOP(1) 1 FROM [dbo].[' + @name + ']) PRINT ''' + @name + ''''
	EXEC sp_executesql @statement
END

CLOSE tablesCur
DEALLOCATE tablesCur
GO

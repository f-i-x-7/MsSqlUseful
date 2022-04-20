DECLARE @TableNameWithSchema SYSNAME,
		@IndexName SYSNAME,
		@SqlQuery NVARCHAR(MAX),
		@SqlQueryParams NVARCHAR(MAX)

DECLARE @Indexes TABLE
(
	TableNameWithSchema SYSNAME,
	IndexName SYSNAME NULL,
	Density DECIMAL(38, 37)
)

DECLARE @Temp TABLE
(
	Density DECIMAL(38, 37),
	AverageLength INT,
	[Columns] NVARCHAR(MAX)
)

INSERT @Indexes(TableNameWithSchema, IndexName, Density)
VALUES('dbo.DIC_CASH_ACCOUNT', 'PK_DIC_CASH_ACCOUNT', NULL)

DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
SELECT TableNameWithSchema, IndexName
FROM @Indexes

OPEN cur

WHILE 1=1
BEGIN
	FETCH cur INTO @TableNameWithSchema, @IndexName

	IF @@FETCH_STATUS <> 0 BREAK

	SET @SqlQuery = 'DBCC SHOW_STATISTICS(@TableNameWithSchema, @IndexName) WITH DENSITY_VECTOR'
	SET @SqlQueryParams = '@TableNameWithSchema SYSNAME, @IndexName SYSNAME'

	DELETE @Temp

	INSERT @Temp(Density, AverageLength, [Columns])
	EXEC sp_executesql @SqlQuery, @SqlQueryParams, @TableNameWithSchema, @IndexName

	UPDATE @Indexes
	SET Density = (SELECT TOP(1) Density FROM @Temp)
	WHERE TableNameWithSchema = @TableNameWithSchema
	AND IndexName = @IndexName
END

CLOSE cur
DEALLOCATE cur

SELECT * FROM @Indexes
GO

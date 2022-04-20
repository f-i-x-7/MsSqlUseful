SET NOCOUNT ON
GO

DECLARE @table VARCHAR(MAX) = '[dbo].[GLOBALS]';
DECLARE @sql VARCHAR(MAX);

DECLARE @dataTypesValuesForNull TABLE
(
	DataType VARCHAR(100) NOT NULL PRIMARY KEY,
	DefaultValueForNull VARCHAR(MAX) NOT NULL
)

INSERT @dataTypesValuesForNull(DataType, DefaultValueForNull)
VALUES
('BIT', '0'),
('TINYINT', '0'),
('SMALLINT', '0'),
('INT', '0'),
('BIGINT', '0'),
('FLOAT', '0'),
('REAL', '0'),
('DECIMAL', '0'),
('NUMERIC', '0'),
('MONEY', '0'),
('CHAR', ''''''),
('NCHAR', ''''''),
('VARCHAR', ''''''),
('NVARCHAR', ''''''),
('DATE', '''19000101'''),
('DATETIME', '''19000101'''),
('BINARY', '0x00'),
('VARBINARY', '0x00')

SET @sql = 'SELECT TOP(10) (0'

-- This select statement collects all columns of a table and calculate datalength
SELECT @sql +=
	CAST(' + DATALENGTH(ISNULL([' AS VARCHAR(MAX)) +
	CAST(C.name AS VARCHAR(MAX)) +
	CAST('], ' AS VARCHAR(MAX)) +
	DT.DefaultValueForNull +
	CAST('))' AS VARCHAR(MAX)) +
	CAST(CHAR(13) AS VARCHAR(MAX)) +
	CAST(CHAR(10) AS VARCHAR(MAX))
FROM sys.columns C
INNER JOIN sys.types T ON C.system_type_id = T.system_type_id AND C.user_type_id = T.user_type_id
INNER JOIN @dataTypesValuesForNull DT ON T.name = DT.DataType
WHERE C.[object_id] = OBJECT_ID(@table)

SET @sql = @sql + ') AS RowSize
FROM ' + @table + '
ORDER BY RowSize DESC'

PRINT @sql
--return
exec (@sql)  
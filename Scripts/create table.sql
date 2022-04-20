SELECT *
INTO #table
FROM dbo.ORDERS_AUTHORIZER
WHERE 1 = 0

DECLARE @tempTablePattern nvarchar(100) = '#table%',
		@columns nvarchar(max) = '',
		@createTableStatement nvarchar(max) = 'CREATE TABLE #Table
(
'

select
	@createTableStatement += char(9) + '[' + COLUMN_NAME + '] ' +
		-- data type
		case
			when DATA_TYPE in ('char', 'nchar', 'varchar', 'nvarchar') THEN UPPER(DATA_TYPE) + '(' + cast(CHARACTER_MAXIMUM_LENGTH as nvarchar(10)) + ')'
			when DATA_TYPE in ('decimal', 'numeric') THEN UPPER(DATA_TYPE) + '(' + cast(NUMERIC_PRECISION as nvarchar(2)) + ', ' + cast(NUMERIC_SCALE as nvarchar(2)) + ')'
			else UPPER(DATA_TYPE)
		end + ' ' +
		-- nullable
		case
			when IS_NULLABLE = 'no' then 'NOT NULL'
			else 'NULL'
		end +
		-- comma
		case
			when ORDINAL_POSITION <> (select count(*) from tempdb.INFORMATION_SCHEMA.COLUMNS where TABLE_NAME like @tempTablePattern) then ','
			else ''
		end + char(13),

	@columns += char(9) + '[' + COLUMN_NAME + ']' +
		case
			when ORDINAL_POSITION <> (select count(*) from tempdb.INFORMATION_SCHEMA.COLUMNS where TABLE_NAME like @tempTablePattern) then ',' + char(13)
			else ''
		end
from tempdb.INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME like @tempTablePattern
order by ORDINAL_POSITION

select @createTableStatement += ')'

select @createTableStatement as [CreateTable]--, @columns as [Columns]

DROP TABLE #table
GO

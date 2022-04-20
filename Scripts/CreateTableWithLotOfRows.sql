IF EXISTS (SELECT 1 FROM sys.objects WHERE [schema_id] = SCHEMA_ID(N'dbo') AND name = 'Test' AND [type] = 'U')
	DROP TABLE dbo.Test;

CREATE TABLE dbo.Test
(
	ID INT NOT NULL,

	DecimalField DECIMAL(38, 7) NOT NULL,
	NvarcharField NVARCHAR(40) NOT NULL,
	BigintField BIGINT NOT NULL,

	Flag BIT NOT NULL,

	CONSTRAINT PK_Test PRIMARY KEY CLUSTERED(ID)
);
GO

DECLARE @numberOfRows BIGINT = 1000000,
		@trueFlagFrequency DECIMAL(10, 4) = 0.001;

WITH Numbers AS
(
	SELECT 1 AS Number
	UNION ALL
	SELECT N.Number + 1 FROM Numbers N WHERE N.Number < @numberOfRows
)
INSERT dbo.Test
(
	ID,
	DecimalField,
	NvarcharField,
	BigintField,
	Flag
)
SELECT
	N.Number AS ID,
	1000000000.123456 AS DecimalField,
	N'Test1Test2Test3Test4Test5' AS NvarcharField,
	1234567890 AS BigintField,
	CASE WHEN N.Number % (1.0 / @trueFlagFrequency) = 0 THEN 1 ELSE 0 END AS Flag
FROM Numbers N
OPTION(MAXRECURSION 0);
GO

CREATE NONCLUSTERED INDEX NIX_Flag ON dbo.Test(Flag);
CREATE NONCLUSTERED INDEX NIX_Flag_Filtered ON dbo.Test(Flag) WHERE Flag=1;
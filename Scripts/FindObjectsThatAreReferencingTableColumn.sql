DECLARE @SearchData TABLE
(
	SchemaName NVARCHAR(128) NOT NULL,
	TableName NVARCHAR(128) NOT NULL,
	ColumnName NVARCHAR(128) NOT NULL,

	FullObjectName AS QUOTENAME(ISNULL(SchemaName, N'dbo')) + N'.' + QUOTENAME(TableName)

	PRIMARY KEY(SchemaName, TableName, ColumnName)
);

INSERT @SearchData(SchemaName, TableName, ColumnName)
VALUES
(N'dbo', N'DIC_CLIENT_FLOW', N'BrokerageAccountID')
--(N'dbo', N'REG_DEAL_CLIENT', N'CouponAmount')
--,(N'dbo', N'REG_DEAL_CLIENT', N'DealValuePriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT', N'PriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'CouponAmount')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'DealValuePriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'PriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT', N'PlanCouponAmount')
--,(N'dbo', N'REG_DEAL_CLIENT', N'PlanDealValuePriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT', N'PlanPriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'PlanCouponAmount')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'PlanDealValuePriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'PlanPriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'CouponAmount')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'DealValuePriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'PriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'PlanCouponAmount')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'PlanDealValuePriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'PlanPriceCcy')
--,(N'dbo', N'REG_DEAL_CLIENT', N'TcComm')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'TcComm')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'TcComm')
--,(N'dbo', N'REG_DEAL_CLIENT', N'CitiBrokerComm')
--,(N'dbo', N'REG_DEAL_CLIENT_ACTIVE', N'CitiBrokerComm')
--,(N'dbo', N'REG_DEAL_CLIENT_HIST', N'CitiBrokerComm')
;

--SELECT DISTINCT *
--FROM
--(
--	SELECT DISTINCT
--		SD.SchemaName,
--		SD.TableName
--	FROM @SearchData SD
--) T
--LEFT JOIN INFORMATION_SCHEMA.COLUMNS C ON T.SchemaName = C.TABLE_SCHEMA
--										AND T.TableName = C.TABLE_NAME

IF EXISTS
(
	SELECT TOP(1) 1
	FROM @SearchData SD
	LEFT JOIN INFORMATION_SCHEMA.COLUMNS C ON SD.SchemaName = C.TABLE_SCHEMA
										AND SD.TableName = C.TABLE_NAME
	WHERE C.TABLE_NAME IS NULL
)
BEGIN;
	THROW 50000, 'Cannot specified table(s).', 1;
END;

IF EXISTS
(
	SELECT TOP(1) 1
	FROM @SearchData SD
	LEFT JOIN INFORMATION_SCHEMA.COLUMNS C ON SD.SchemaName = C.TABLE_SCHEMA
										AND SD.TableName = C.TABLE_NAME
										AND SD.ColumnName = C.COLUMN_NAME
	WHERE C.COLUMN_NAME IS NULL
)
BEGIN;
	THROW 50000, 'Cannot find specified column(s) in specified table(s).', 1;
END;

SELECT DISTINCT -- distinct was added together with support of search by several columns
	T.ReferencingObjectName,
	o.[type_desc] AS ReferencingObjectType
FROM @SearchData SD
CROSS APPLY sys.dm_sql_referencing_entities(SD.FullObjectName, N'object') refing
CROSS APPLY
(
	SELECT
		QUOTENAME(refing.referencing_schema_name) + N'.' + QUOTENAME(refing.referencing_entity_name) AS ReferencingObjectName
) T
CROSS APPLY sys.dm_sql_referenced_entities(T.ReferencingObjectName, N'object') refed
INNER JOIN sys.objects o ON refing.referencing_id = o.[object_id]
WHERE refed.referenced_schema_name = SD.SchemaName
AND refed.referenced_entity_name = SD.TableName
AND refed.referenced_minor_name = SD.ColumnName
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
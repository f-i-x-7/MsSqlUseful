CREATE TABLE #sp_who2
(
	SPID INT NOT NULL,
	[Status] VARCHAR(255) NOT NULL,
	[Login] VARCHAR(255) NOT NULL,
	HostName VARCHAR(255) NOT NULL,
	BlkBy VARCHAR(255) NOT NULL,
	DBName VARCHAR(255) NULL,
	Command VARCHAR(255) NOT NULL,
	CPUTime INT NOT NULL,
	DiskIO INT NOT NULL,
	LastBatch VARCHAR(255) NOT NULL,
	ProgramName VARCHAR(255) NOT NULL,
	SPID2 INT NOT NULL,
	REQUESTID INT NOT NULL
)

INSERT INTO #sp_who2
EXEC sp_who2

SELECT *
FROM #sp_who2
WHERE SPID <> @@SPID
AND DBName = 'SOBOS_20171206_SWIFT'
AND HostName <> 'EPRURYAW0108'
ORDER BY DBName ASC

DROP TABLE #sp_who2
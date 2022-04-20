/******************************************************************************
**    File: “GetTableSpaceUseage.sql”
**    Name: Get Table Space Useage for a specific schema
**    Auth: Robert C. Cain
**    Date: 01/27/2008
**
**    Desc: Calls the sp_spaceused proc for each table in a schema and returns
**        the Table Name, Number of Rows, and space used for each table.
**
**    Called by:
**     n/a – As needed
**
**    Input Parameters:
**     In the code check the value of @schemaname, if you need it for a
**     schema other than dbo be sure to change it.
**
**    Output Parameters:
**     NA
*******************************************************************************/

/*—————————————————————————*/
/* Drop the temp table if it's there from a previous run                     */
/*—————————————————————————*/
if object_id(N'tempdb..[#TableSizes]') is not null
  drop table #TableSizes ;
go

/*—————————————————————————*/
/* Create the temp table                                                     */
/*—————————————————————————*/
create table #TableSizes
  (
    [Schema Name] NVARCHAR(256)
  , [Table Name] nvarchar(128)   /* Name of the table */
  , [Number of Rows] char(11)    /* Number of rows existing in the table. */
  , [Reserved Space] varchar(18) /* Reserved space for table. */
  , [Data Space] varchar(18)    /* Amount of space used by data in table. */
  , [Index Size] varchar(18)    /* Amount of space used by indexes in table. */
  , [Unused Space] varchar(18)   /* Amount of space reserved but not used. */
  ) ;
go

/*—————————————————————————*/
/* Load the temp table                                                        */
/*—————————————————————————*/
-- Create a cursor to cycle through the names of each table in the schema
declare curSchemaTable cursor
  for select sys.schemas.name, sys.schemas.name + '.' + sys.objects.name
      from    sys.objects
    		, sys.schemas
      where   object_id > 100
    		  /* For a specific table uncomment next line and supply name */
    		  --and sys.objects.name = 'specific-table-name-here'    
    		  and type_desc = 'USER_TABLE'
    		  and sys.objects.schema_id = sys.schemas.schema_id ;

open curSchemaTable ;
declare @schemaname varchar(256),
		@name varchar(256) ;  /* This holds the name of the current table*/

-- Now loop thru the cursor, calling the sp_spaceused for each table
fetch curSchemaTable into @schemaname, @name ;
while ( @@FETCH_STATUS = 0 )
  begin    
    insert into #TableSizes([Table Name], [Number of Rows], [Reserved Space], [Data Space], [Index Size], [Unused Space])
    		exec sp_spaceused @objname = @name ;       

    update #TableSizes set [Schema Name] = @schemaname WHERE [Schema Name] IS null

    fetch curSchemaTable into @schemaname, @name ;   
  end

/* Important to both close and deallocate! */
close curSchemaTable ;     
deallocate curSchemaTable ;


/*—————————————————————————*/
/* Feed the results back                                                     */
/*—————————————————————————*/
SELECT [Schema Name]
      , [Table Name]
      , [Number of Rows]
      , CAST(REPLACE([Reserved Space], 'KB', '') AS BIGINT) AS [Reserved Space, KB]
      , CAST(REPLACE([Data Space], 'KB', '') AS BIGINT) AS [Data Space, KB]
      , CAST(REPLACE([Index Size], 'KB', '') AS BIGINT) AS [Index Size, KB]
      , CAST(REPLACE([Unused Space], 'KB', '') AS BIGINT) AS [Unused Space, KB]
	  , CAST(CAST(REPLACE([Reserved Space], 'KB', '') AS BIGINT) AS DECIMAL(38, 8)) / 1024 / 1024 AS [Reserved Space, GB]
      , CAST(CAST(REPLACE([Data Space], 'KB', '') AS BIGINT) AS DECIMAL(38, 8)) / 1024 / 1024 AS [Data Space, GB]
      , CAST(CAST(REPLACE([Index Size], 'KB', '') AS BIGINT) AS DECIMAL(38, 8)) / 1024 / 1024 AS [Index Size, GB]
      , CAST(CAST(REPLACE([Unused Space], 'KB', '') AS BIGINT) AS DECIMAL(38, 8)) / 1024 / 1024 AS [Unused Space, GB]
from    [#TableSizes]
order by [Reserved Space, KB] desc ;

/*—————————————————————————*/
/* Remove the temp table                                                     */
/*—————————————————————————*/
drop table #TableSizes ;
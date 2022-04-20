select object_name(i.object_id) as object_name, i.name, ips.*
from sys.dm_db_index_physical_stats(db_id(), default, default, default, default) ips
inner join sys.indexes i on ips.object_id = i.object_id and ips.index_id = i.index_id
WHERE i.object_id = OBJECT_ID('Derivatives.CorporateBrokerageCashRegisterTransactions')
order by ips.avg_fragmentation_in_percent desc

select *
from sys.dm_db_index_operational_stats(db_id(), default, default, default)

select * from sys.dm_db_index_usage_stats where database_id = db_id()
select * from sys.indexes where object_id = 347304447

select * from sys.dm_db_missing_index_details where database_id = db_id()
select * from sys.dm_db_missing_index_columns(23)
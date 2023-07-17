

SELECT * 
FROM PortfolioProjects..my_operational_data_operations_$

--- The title for the last column, Machine_id, does not follow the same format as the other columns, so we will need to fix it to fit the naming of the other columns


EXEC sp_rename 'PortfolioProjects..my_operational_data_operations_$.Machine_id', 'machine_id', 'COLUMN'

--- Next I want to see if there are NULL values
SELECT * 
FROM PortfolioProjects..my_operational_data_operations_$
WHERE machine_id IS NULL

--- There are no NULL values, meaning we do not have to try to populate or find missing data

--- Now I want to make sure that there aren't two machine_code's that go to the same machine_id
SELECT * 
FROM PortfolioProjects..my_operational_data_operations_$ a
JOIN PortfolioProjects..my_operational_data_operations_$ b 
	ON a.machine_code = b.machine_code
WHERE a.machine_code = b.machine_code AND a.machine_id <> b.machine_id

--- There aren't two machine_code's that go to the same machine_id, so we know that refering to either or both would work

--- Now I want to search for duplicates in the data
WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER (
		PARTITION BY date,
					 uptime,
					 downtime,
					 machine_id
					 ORDER BY
					 machine_id,
					 machine_code
					 ) AS row_num
FROM PortfolioProjects..my_operational_data_operations_$
--ORDER BY machine_code
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1

--- There are no duplicates in the data

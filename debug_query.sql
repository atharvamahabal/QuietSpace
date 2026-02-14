-- Diagnostic query to check data availability
SELECT 'Available machine groups' as check_type, machine_group, COUNT(*) as record_count
FROM transactions.energy_by_machine_group_pct 
WHERE machine_group IS NOT NULL 
GROUP BY machine_group

UNION ALL

SELECT 'Available period types' as check_type, period_type, COUNT(*) as record_count  
FROM transactions.energy_by_machine_group_pct 
GROUP BY period_type

UNION ALL

SELECT 'Sample records for daily period' as check_type, 
       CONCAT('Machine: ', machine_group, ' | Energy: ', machine_group_energy_used) as details,
       1 as record_count
FROM transactions.energy_by_machine_group_pct 
WHERE period_type = 'daily'
LIMIT 5

UNION ALL

SELECT 'Machine group mapping check' as check_type,
       CASE 
         WHEN machine_group IN ('CNC Contouring', 'CNC Turning', 'CNC EDM Cutting') THEN 'CNC' 
         WHEN machine_group IN ('Tempering Furnace', 'Vacuum Furnace', 'Nitriding Furnace') THEN 'Furnace' 
         WHEN machine_group IN ('Medium Twin-Headed Milling', 'Big Face Milling') THEN 'Milling' 
         WHEN machine_group IN ('Surface Grinding') THEN 'Grinding' 
         WHEN machine_group IN ('Round Piece Machine', 'Small Size Machine', 'Medium Size Machine') THEN 'Sawing' 
         ELSE 'UNMAPPED'
       END AS machine_type,
       COUNT(*) as record_count
FROM transactions.energy_by_machine_group_pct 
WHERE machine_group IS NOT NULL 
GROUP BY machine_type

ORDER BY check_type, record_count DESC;
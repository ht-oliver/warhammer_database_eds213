--- Tables
-- datasheets
-- I want to find out which faction has the most affordable models
-- for each size of model
SELECT 
    f.faction_name AS faction,
    m.size,
    ROUND(AVG(mc.cost), 2) AS avg_cost
FROM datasheets d
JOIN models m ON d.model_id = m.model_id
JOIN model_cost mc ON d.model_id = mc.model_id
JOIN factions f ON d.faction_id = f.faction_id
WHERE m.size IS NOT NULL
GROUP BY f.faction_name, m.size
ORDER BY f.faction_name, m.size;
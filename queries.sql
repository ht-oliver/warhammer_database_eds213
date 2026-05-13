
-- I want to find out which faction has the most affordable models for each size of model
SELECT 
    f.faction_name AS faction,
    m.size,
    ROUND(AVG(mc.cost), 2) AS avg_cost -- Find the average cost of models, round to two decimals
FROM datasheets d -- Join from datasheets, this is our primary table
JOIN models m ON d.model_id = m.model_id -- Join on model_id, the primary key
JOIN model_cost mc ON d.model_id = mc.model_id -- Join on model_cost to get costs
JOIN factions f ON d.faction_id = f.faction_id -- Join to factions to get faction names
WHERE m.size IS NOT NULL -- Remove observations with no size value
GROUP BY f.faction_name, m.size -- Group by faction name, then by size to get model sizes per faction
ORDER BY f.faction_name, m.size; -- Order by faction name, and then small to large. Put some order to the chaos



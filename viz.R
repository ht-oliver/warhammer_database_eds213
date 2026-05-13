library(DBI)
library(duckdb)
library(ggplot2)
library(scales)

# Connect to database
con <- dbConnect(duckdb(), dbdir = "wh_database.duckdb", read_only = TRUE)

# Run query
query <- "
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
  ORDER BY f.faction_name, m.size
"

warhammer_df <- dbGetQuery(con, query)
dbDisconnect(con)

# Order size correctly
warhammer_df$size <- factor(warhammer_df$size, levels = c("small", "medium", "large"))

# Plot
ggplot(warhammer_df, aes(x = size, y = avg_cost, fill = size)) +
  geom_col() +
  facet_wrap(~ faction) +
  scale_y_continuous(labels = dollar) +
  labs(title = "Average Model Cost by Size and Faction",
       x = "Size", y = "Average Cost") +
  theme_minimal() +
  theme(legend.position = "none")
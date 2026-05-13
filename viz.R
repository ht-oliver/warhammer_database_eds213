library(DBI)
library(duckdb)
library(ggplot2)
library(scales)
library(dplyr)

# Connect to database
con <- dbConnect(duckdb(), dbdir = "wh_database.duckdb", read_only = TRUE)

# Define query
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

# Run query and disconnect
warhammer_df <- dbGetQuery(con, query)
dbDisconnect(con)

# Remove factions that odn't have all three sizes
exclude_factions <- c('Astra Militarum', 'Chaos Space Marines', 'Necrons', 'Thousand Sons', 'Unaligned Forces', 'Adeptus Titanicus', 'Adepta Sororitas', 'Genestealer Cults', 'Leagues of Votann')
warhammer_df <- warhammer_df |>
  filter(!faction %in% exclude_factions)

# Order sizes from small to large
warhammer_df$size <- factor(warhammer_df$size, levels = c("small", "medium", "large"))

wh_palette <- c(
  "#8B0000",  # Mephiston Red (Adeptus Custodes)
  "#1C3A6B",  # Macragge Blue (Adeptus Mechanicus)
  "#2D5A1B",  # Caliban Green (Aeldari)
  "#999999",  # Abaddon Grey (Chaos Daemons)
  "#C7B07B",  # Screaming Skull (Chaos Knights)
  "#7B2D8B",  # Xereus Purple (Death Guard)
  "#B5A45A",  # Auric Armour Gold (Drukhari)
  "#4A7C59",  # Warpstone Glow (Emperor's Children)
  "#8B6914",  # Hashut Copper (Grey Knights)
  "#2E4B6B",  # The Fang (Imperial Agents)
  "#5C1A1A",  # Khorne Red (Imperial Knights)
  "#3B5E3B",  # Loren Forest (Orks)
  "#6B4C2A",  # Rhinox Hide (Space Marines)
  "#4A4A6B",  # Incubi Darkness (Tau Empire)
  "#8B7355",  # Karak Stone (Tyranids
  "#E5E1D0"   # Kantor Blue (World Eaters)
)

library(showtext)
font_add_google("Cinzel", "cinzel")
showtext_auto()

ggplot(warhammer_df, aes(x = faction, y = avg_cost, fill = faction)) +
  geom_col() +
  scale_fill_manual(values = wh_palette) +
  facet_wrap(~ size, ncol = 1) + # One barchart per model size
  scale_y_continuous(labels = dollar) + # Add $ to cost label
  labs(title = "Average Model Cost by Faction and Size",
       x = "Faction", y = "Average Cost") +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, color = "#c7b07b", family = "cinzel"),
    plot.background = element_rect(fill = "#1a1a1a"),
    panel.background = element_rect(fill = "#2a2a2a"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(color = "#444444"),
    axis.text = element_text(color = "#c7b07b", family = "cinzel", size = 12, face = "bold"),
    axis.title = element_text(color = "#c7b07b", family = "cinzel", size = 16),
    strip.text = element_text(color = "#c7b07b", face = "bold", family = "cinzel", size = 16),
    plot.title = element_text(color = "#c7b07b", hjust = 0.5, family = "cinzel", size = 22)
  )
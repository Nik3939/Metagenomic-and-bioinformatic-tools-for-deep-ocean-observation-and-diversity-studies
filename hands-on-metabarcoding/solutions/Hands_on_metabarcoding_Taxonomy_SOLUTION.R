## Hands on metabarcoding - Taxonomy
## Exercises

## Relative abundance

# Calculate relative abundance, per sample
ASVs_full <- ASVs_full %>% 
  group_by(Sample) %>% 
  mutate(RelativeAbundance = Abundance*100/sum(Abundance))

## Plot Kingdom level information

# Make a bar plot of Kingdom relative abundance
ASVs_full %>% 
  ggplot(aes(x = Sample, y = RelativeAbundance, fill = Kingdom)) + 
  geom_col() + 
  theme_bw() + 
  theme(axis.text.x = element_text(size = 12, angle = 90),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.position = "top") + 
  labs(y = "Relative abundance (%)")

# Add an horizontal line at 75 relative abundance
ASVs_full %>% 
  group_by(Sample, Kingdom) %>% 
  summarise(RelativeAbundance = sum(RelativeAbundance)) %>% 
  ggplot(aes(Sample, RelativeAbundance, fill = Kingdom)) + 
  geom_col() + 
  geom_hline(yintercept = 75, lty = "dashed") + 
  theme_bw() + 
  theme(axis.text.x = element_text(size = 14, angle = 90),
        axis.text.y = element_text(size = 14),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 16), 
        legend.title = element_text(size = 16),
        panel.grid = element_blank(),
        legend.position = "top") + 
  labs(y = "Relative abundance (%)")

# Divide the plot in grids for Experiment and Replicate
ASVs_full %>% 
  group_by(Sample, Experiment, Treatment, Concentration, Replicate, Kingdom) %>% 
  summarise(RelativeAbundance = sum(RelativeAbundance)) %>% 
  ggplot(aes(x = Treatment, y = RelativeAbundance, 
             fill = Kingdom)) + 
  geom_col() +
  facet_grid(rows = c("Experiment", "Replicate")) + 
  theme_bw() +
  theme(axis.text.x = element_text(size = 12, angle = 90),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.text = element_text(size = 14), legend.title = element_text(size = 14),
        panel.grid = element_blank(),
        legend.position = "top",
        strip.background = element_blank(), strip.text = element_text(size = 14)) + 
  labs(y = "Relative abundance (%)")

# Use point and line plot instead of bar plot, divide grids by Experiment
ASVs_full %>% 
  group_by(Sample, Experiment, Treatment, Concentration, Replicate, Kingdom) %>% 
  summarise(RelativeAbundance = sum(RelativeAbundance)) %>% 
  ggplot(aes(x = Treatment, y = RelativeAbundance, col = Kingdom)) +
  # add a layer with points
  geom_point(size = 2.5) +
  geom_vline(xintercept = 1.5, lty = "dashed") +
  facet_grid(~Experiment) + 
  theme_bw() +
  theme(axis.text.x = element_text(size = 12, angle = 90),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.position = "top",
        legend.text = element_text(size = 14),
        legend.title = element_text(size= 14),
        strip.background = element_blank(),
        strip.text = element_text(size = 14),
        panel.grid.minor = element_blank()) +
  labs(y = "Relative abundance (%)")

## Plot phylum level

# Find the 5 most abundant phyla
top5_phyla <- ASVs_full %>% 
  group_by(Phylum) %>% 
  summarise(totalAbundance = sum(Abundance)) %>% 
  arrange(desc(totalAbundance)) %>% 
  head(n = 5) %>% 
  pull(Phylum)

# Prepare data for stacked bar plot
top_phylum_data <- ASVs_full %>% 
  group_by(Sample, Experiment, Treatment, 
           Concentration, Replicate, Phylum) %>% 
  summarise(RelativeAbundance = sum(RelativeAbundance)) %>% 
  mutate(topPhyla = ifelse(Phylum %in% top5_phyla, Phylum, "Other")) %>% 
  mutate(topPhyla = factor(topPhyla, levels = c(top5_phyla, "Other")))

# Make the plot using top_phylum_data and store it as stacked_bar_plot_phylum
stacked_bar_plot_phylum <- top_phylum_data %>% 
  ggplot(aes(x = Treatment, y = RelativeAbundance, fill = topPhyla)) + 
  geom_col() +
  facet_grid(rows = c("Experiment", "Replicate"))

# Add editing layers
stacked_bar_plot_phylum + 
  theme_bw() +
  theme(axis.text.x = element_text(size = 12, angle = 90),
       axis.text.y = element_text(size = 12),
       axis.title = element_text(size = 12),
       legend.position = "top",
       strip.background = element_blank(),
       strip.text = element_text(size= 12)) + 
  labs(y = "Relative abundance (%)",
       fill = "Top phyla") + 
  scale_fill_manual(values = c(qualitative_colors[1:5], "grey80"))

# Repeat the same plot as point and line plot instead
top_phylum_data %>% 
  ggplot(aes(x = Treatment, y = RelativeAbundance, col = topPhyla)) + 
  geom_jitter(width = 0.1, size = 3) +
  geom_vline(xintercept = 1.5, lty = "dashed") +
  facet_grid(~Experiment) + 
  theme_bw() +
  theme(axis.text.x = element_text(size = 12, angle = 90),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.position = "top", legend.text = element_text(size = 12), 
        legend.title = element_text(size= 12),
        strip.background = element_blank(),
        strip.text = element_text(size = 14)) + 
  labs(y = "Relative abundance (%)", color = "Phyla: ") + 
  scale_color_manual(values = c(qualitative_colors[1:5], "grey80"))

## Plot Genus level

# Identify the 5 most abundant genera, don't forget some genera are unclassified (NA)
top5_genera <- ASVs_full %>%
  group_by(Genus) %>% 
  summarise(totalAbundance = sum(Abundance)) %>% 
  arrange(desc(totalAbundance)) %>% 
  head(n = 6) %>% 
  pull(Genus)

# print result
top5_genera

# Prepare the Genus data to plot later
top_genus_data <- ASVs_full %>% 
  group_by(Sample, Experiment, Treatment, Concentration, Replicate, Genus) %>% 
  summarise(RelativeAbundance = sum(RelativeAbundance)) %>% 
  mutate(topGenus = ifelse(Genus %in% top5_genera, Genus, "Other"),
         topGenus = ifelse(is.na(topGenus), "Unknown", topGenus)) %>% 
  mutate(topGenus = factor(topGenus, levels = c(top5_genera, "Unknown", "Other"))) 

# Make a point  plot
top_genus_data %>% 
  # set up the ggplot
  ggplot(aes(Treatment, RelativeAbundance, col = topGenus)) +
  # add point layer
  geom_jitter(width = 0.1, size = 3) +
  # add facet grid
  facet_grid(~Experiment) +
  # use theme black and white
  theme_bw() +
  # add theme details manually
  theme(axis.text.x = element_text(size = 12, angle = 90),
       axis.text.y = element_text(size = 12),
       axis.title = element_text(size = 14),
       legend.position = "top",
       legend.text = element_text(size = 12),
       legend.title = element_text(size= 12),
       strip.background = element_blank(),
       strip.text = element_text(size = 14)) +
  labs(y = "Relative abundance (%)", color = "Genus: ") + 
  scale_color_manual(values = c(qualitative_colors[1:5], "grey41","grey80"))

## Closer look at Stenotrophomonas

# Highlight Stenotrophomonas
top_genus_data %>% 
  mutate(isSteno = ifelse(Genus == "Stenotrophomonas", "Stenotrophomonas", "Other")) %>% 
  ggplot(aes(Treatment, RelativeAbundance, col = isSteno)) +
  geom_jitter(width = 0.1) +
  facet_grid(~Experiment) +
  theme_bw() +
  theme(axis.text.x = element_text(size = 12, angle = 90),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.position = "top",
        legend.text = element_text(size = 12),
        legend.title = element_text(size= 12),
        strip.background = element_blank(),
        strip.text = element_text(size = 14)) +
  labs(y = "Relative abundance (%)", color = "Genus: ") + 
  scale_color_manual(values = c("grey80", "red", "grey20"))

# Calculate relative abundance and filter for the Stenotrophomonas genus, store in steno_data
steno_data <- ASVs_full %>% 
  group_by(Sample, Experiment, Treatment, 
           Concentration, Replicate, Genus) %>% 
  summarise(RelativeAbundance = sum(RelativeAbundance)) %>%
  filter(Genus == "Stenotrophomonas") 

# Plot relative abundance as a function of Cd Concentration, as steno_plot
steno_plot <- steno_data %>% 
  ggplot(aes(x = Concentration,
             y = RelativeAbundance)) + 
  geom_point() + 
  geom_smooth(se = FALSE, 
              method = "lm",
              lty = "dashed",
              col = "black")

# Add some editing on top of steno_plot
steno_plot +
theme_bw()  +
  theme(panel.grid.minor = element_blank(),
       axis.text = element_text(size = 12),
       axis.title = element_text(size = 14)) + 
  labs(y = "Relative abundance (%)",
       x = "Cd [\U00B5M]")


## End
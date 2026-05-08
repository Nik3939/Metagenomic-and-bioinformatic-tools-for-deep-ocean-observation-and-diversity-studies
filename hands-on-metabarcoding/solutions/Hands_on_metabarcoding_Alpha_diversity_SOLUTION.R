### Hands on metabarcoding - Alpha diversity
### Exercises

## Prepare species abundance table

# Make a species abundance table matrix:
# 1. select columns with samples and abundance values
ASVs_wide <- ASV_combined_clean[, rownames(seqtab.nochim)]
ASVs_wide$Sequence <- NULL

# 2. switch rows and columns with t()
ASVs_wide_t <- t(ASVs_wide)

## Calculate alpha diversity

# Calculate Species Richness of the ASVs_wide_t object
specnumber(ASVs_wide_t)

# The help page can help you
help(diversity)
# Shannon index
diversity(ASVs_wide_t, index = "shannon")
# Simpson index
diversity(ASVs_wide_t, index = "simpson")
# inverse Simpson index
diversity(ASVs_wide_t, index = "invsimpson")

## Overview results with base R

# Make a bar plot of Shannon diversity
shannon_diversity <- diversity(ASVs_wide_t, index = "shannon")
barplot(height = shannon_diversity, las = 2, col = qualitative_colors[1],
        main = "Alpha diversity", ylab = "Shannon index") 

## Optimize diversity calculation with dplyr metrics

# Calculate diversity
diversity_summary <- ASVs_full %>% 
  group_by(Sample, Experiment, Treatment, 
           Concentration, Replicate) %>%
  summarise(speciesRichness = specnumber(Abundance),
            shannon = diversity(Abundance, 
                           index = "shannon"),
            simpson = diversity(Abundance, 
                                index = "simpson"),
            invsimpson = diversity(Abundance, 
                              index = "invsimpson"))

diversity_summary <- diversity_summary %>% 
  mutate(isControl = ifelse(Treatment == "CTR", "Control", "Cd treatment"))

# Inspect diversity summary object
colnames(diversity_summary)
View(diversity_summary)


## Overview the summary with ggplot2

# Using the diversity_summary data frame and ggplot2, plot species richness:
diversity_summary %>% 
  ggplot(aes(x = Sample, y = speciesRichness)) + 
  geom_point(size = 3) + 
  theme_classic() + 
  theme(axis.text.x = element_text(size = 12, angle = 90),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14)) + 
  labs(y = "Number of ASVs")

## Reflect the experiment in the plot (1)

# Make a Control vs Treatment column
diversity_summary <- diversity_summary %>% 
  mutate(isControl = ifelse(Treatment == "CTR", "Control", "Cd treatment"))

# Plot species richness as a function of Concentration
diversity_summary %>% 
  ggplot(aes(x = Treatment, y = speciesRichness, 
             col = isControl)) + 
  geom_point(size = 4) + 
  facet_grid(~Experiment) + 
  theme_classic() + 
  scale_color_manual(values = c("#009E73", "grey40")) + 
  labs(y = "Species richness",
       x = "Concentration (\U00B5M)",
       col = "Group")

# Repeat the previous plot, using Treatment instead of Experiment
diversity_summary %>% 
  ggplot(aes(x = Treatment, y = speciesRichness, 
             col = isControl)) + 
  geom_point(size = 4) + 
  facet_grid(~Experiment) + 
  theme_classic() + 
  scale_color_manual(values = c("#009E73", "grey40")) + 
  labs(y = "Species richness",
       x = "Concentration (\U00B5M)",
       col = "Group")

## Perfecting your plot

# Save the first part of your plot as plot_1
plot_1 <- diversity_summary %>% 
  ggplot(aes(x = Treatment, y = speciesRichness, 
             col = isControl)) + 
  geom_point(size = 4) + 
  facet_grid(~Experiment) + 
  theme_classic() + 
  scale_color_manual(values = c("#009E73", "grey40")) + 
  labs(y = "Species richness",
       x = "Concentration (\U00B5M)",
       col = "Group")

# Use theme() function to improve plot_1
plot_1 + 
  theme(axis.title = element_text(size = 16),
       axis.text.x = element_text(size = 14, 
                                  angle = 45, hjust = 1),
       axis.text.y = element_text(size = 14),
       strip.text = element_text(size = 16, face = "bold"),
       strip.background = element_blank(),
       legend.title = element_text(size = 16),
       legend.text = element_text(size = 16),
       legend.position = "top")

## Repeat the same analysis for Shannon index

# Make plot_shannon
plot_shannon <- diversity_summary %>% 
  ggplot(aes(x = Treatment, y = shannon)) + 
  geom_point(size = 4) + 
  facet_grid(~Experiment) + 
  theme_classic() + 
  scale_color_manual(values = qualitative_colors) + 
  labs(y = "Shannon",
       x = "Concentration (\U00B5M)")

# Use theme() function to improve plot_shannon
plot_shannon + 
  theme(axis.title = element_text(size = 16),
       axis.text.x = element_text(size = 14, 
                                  angle = 45, hjust = 1),
       axis.text.y = element_text(size = 14),
       strip.text = element_text(size = 16, face = "bold"),
       strip.background = element_blank(),
       legend.title = element_text(size = 16),
       legend.text = element_text(size = 16),
       legend.position = "top")

## Focus on Sed037

# Filter samples from the Experiment Sed037
Sed0037_experiment <- diversity_summary %>% filter(Experiment == "Sed037")

# Plot species richness as Sed037_sr_plot
Sed037_sr_plot <- Sed0037_experiment %>% 
  ggplot(aes(x = Treatment, y = speciesRichness, col = isControl)) + 
  geom_point(size = 3) + 
  geom_hline(yintercept = c(550, 650), lty = "dashed") + 
  theme_classic() + 
  scale_color_manual(values = c("#009E73", "grey40")) + 
  labs(y = "Species richness",
       x = "Concentration (\U00B5M)",
       col= "Group")

# Repeat for Shannon index
Sed037_sh_plot <- Sed0037_experiment %>% 
  ggplot(aes(x = Treatment, y = shannon, col = isControl)) + 
  geom_point(size = 3) + 
  theme_classic() + 
  scale_color_manual(values = c("#009E73", "grey40")) + 
  labs(y = "Shannon",
       x = "Concentration (\U00B5M)",
       col = "Group")

# Add the previous edits to the new plots
# Species richness
Sed037_sr_plot <- Sed037_sr_plot + 
  theme(axis.title = element_text(size = 16),
        axis.text.x = element_text(size = 14, 
                                   angle = 45, hjust = 1),
        axis.text.y = element_text(size = 14),
        strip.text = element_text(size = 16, face = "bold"),
        strip.background = element_blank(),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 16),
        legend.position = "top")
# Shannon index
Sed037_sh_plot <- Sed037_sh_plot + 
  theme(axis.title = element_text(size = 16),
        axis.text.x = element_text(size = 14, 
                                   angle = 45, hjust = 1),
        axis.text.y = element_text(size = 14),
        strip.text = element_text(size = 16, face = "bold"),
        strip.background = element_blank(),
        legend.title = element_text(size = 16),
        legend.text = element_text(size = 16),
        legend.position = "top")

# Combine the objects Sed037_sr_plot and Sed037_sh_plot in a single plot
grid.arrange(Sed037_sr_plot, Sed037_sh_plot, ncol = 2, nrow = 1)

## Verify parametric requisites 

# identify extreme outliers
Sed0037_experiment %>% 
  group_by(Treatment) %>% 
  identify_outliers("shannon")

# verify normal distribution
Sed0037_experiment %>% 
  group_by(Treatment) %>% 
  shapiro_test(shannon)

# check homogeneity of variance
Sed0037_experiment %>% 
  ungroup() %>% 
  levene_test(shannon ~ Treatment)

# One-way ANOVA
Sed0037_experiment %>% 
  ungroup() %>%  
  anova_test(shannon ~ Treatment) 

# post hoc test
ptt <- Sed0037_experiment %>% 
  ungroup() %>% 
  tukey_hsd(shannon ~ Treatment, paired = TRUE)

# Check significant groups
ptt %>% 
  filter(p.adj.signif != "ns")
# end 
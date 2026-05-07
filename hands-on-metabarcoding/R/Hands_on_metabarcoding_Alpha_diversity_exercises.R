### Hands on metabarcoding - Alpha diversity
### Exercises

## Prepare species abundance table

# Make a species abundance table matrix:
# 1. select columns with samples and abundance values
ASVs_wide <- ASV_combined_clean[, rownames(____)]
ASVs_wide$Sequence <- NULL

# 2. switch rows and columns with t()
ASVs_wide_t <- ____(ASVs_wide)

## Calculate alpha diversity

# Calculate Species Richness of the ASVs_wide_t object
____(____)

# The help page can help you
help(diversity)
# Shannon index
____(ASVs_wide_t, index = "shannon")
# Simpson index
____(ASVs_wide_t, index = ____)
# inverse Simpson index
____(____, ____)

## Overview results with base R

# Make a bar plot of Shannon diversity
shannon_diversity <- diversity(ASVs_wide_t, index = "shannon")
barplot(height = ____, las = 2, col = qualitative_colors[1],
        main = "Alpha diversity", ylab = "Shannon index") 

## Optimize diversity calculation with dplyr metrics

# Calculate diversity
diversity_summary <- ASVs_full %>% 
  group_by(Sample, Experiment, Treatment, 
           Concentration, Replicate) %>%
  summarise(speciesRichness = ____(Abundance),
            shannon = ____(Abundance, 
                           index = "shannon"),
            simpson = diversity(____, 
                                index = "____"),
            invsimpson = ____(____, 
                              index = "____"))
#
diversity_summary <- diversity_summary %>% 
  mutate(isControl = ifelse(Treatment == "CTR", "Control", "Cd treatment"))

# Inspect diversity summary object
colnames(____)
View(____)

## Overview the summary with ggplot2

# Using the diversity_summary data frame and ggplot2, plot species richness:
____ %>% 
ggplot(aes(x = ____, y = ____)) + 
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
  ggplot(aes(x = ____, y = ____, 
             col = ____)) + 
  geom_point(size = 3) + 
  facet_grid(~____) + 
  scale_x_log10() +
  scale_color_manual(values = c("#009E73", "grey40")) + 
  theme_classic() + 
  labs(y = "Species richness",
       x = "Concentration (\U00B5M) in Log10 scale")

# Repeat the previous plot, using Treatment instead of Experiment
diversity_summary %>% 
  ggplot(aes(x = ____, y = speciesRichness, 
             col = isControl)) + 
  geom_point(size = 4) + 
  facet_grid(~Experiment) + 
  scale_color_manual(values = c("#009E73", "grey40")) + 
  theme_classic() + 
  labs(y = "Species richness",
       x = "Concentration (\U00B5M)")

## Perfecting your plot

# Save the first part of your plot as plot_1
____ <- diversity_summary %>% 
  ggplot(aes(x = Treatment, y = speciesRichness, 
             col = isControl)) + 
  geom_point(size = ____) + 
  facet_grid(~Experiment) + 
  scale_color_manual(values = c("#009E73", "grey40")) + 
  theme_classic() + 
  labs(y = "Species richness",
       x = "Concentration (\U00B5M)")

# Use theme() function to improve plot_1
____ + 
  ____(axis.title = element_text(size = 16),
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
____ <- diversity_summary %>% 
  ggplot(aes(x = Treatment, y = ____, 
             col = isControl)) + 
  geom_point(size = 4) + 
  facet_grid(~Experiment) + 
  theme_classic() + 
  scale_color_manual(values = c("#009E73", "grey40")) +
  labs(y = "Shannon",
       x = "Concentration (\U00B5M)")

# Use theme() function to improve plot_shannon
____ + 
  ____(axis.title = element_text(size = 16),
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
Sed0037_experiment <- diversity_summary %>% filter(____)

# Plot species richness as Sed037_sr_plot
____ <- Sed0037_experiment %>% 
  ggplot(aes(x = Treatment, y = ____, 
             col = Replicate)) + 
  geom_point(size = 4) + 
  geom_hline(yintercept = c(550, 650), lty = "dashed") + 
  theme_classic() + 
  scale_color_manual(values = c("#009E73", "grey40")) +
  labs(y = "Species richness",
       x = "Concentration (\U00B5M)")

# Repeat for Shannon index
Sed037_sh_plot <- Sed0037_experiment %>% 
  ggplot(aes(x = Treatment, y = shannon, 
             col = Replicate)) + 
  geom_point(size = 3) +
  scale_color_manual(values = c("#009E73", "grey40")) + 
  theme_classic() + 
  labs(y = "Shannon",
       x = "Concentration (\U00B5M)")

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

# Combine the plots Sed037_sr_plot and Sed037_sh_plot in a single plot
____(____, ____, ncol = 2, nrow = 1)

## Verify parametric requisites 

# Identify extreme outliers
Sed0037_experiment %>% 
  group_by(Treatment) %>% 
  ____("shannon")

# Verify normal distribution
Sed0037_experiment %>% 
  group_by(Treatment) %>% 
  ____(shannon)

## One-way ANOVA

# Perform the ANOVA test
Sed0037_experiment %>% 
  ungroup() %>%  
  ____(shannon ~ Treatment) 

# Do Tukey test (post-hoc)
Sed0037_experiment %>% 
  ungroup() %>% 
  ____(shannon ~ Treatment, paired = TRUE)

# Identify significant tests
ptt %>% 
  filter(p.adj.signif ____ "ns")

## end


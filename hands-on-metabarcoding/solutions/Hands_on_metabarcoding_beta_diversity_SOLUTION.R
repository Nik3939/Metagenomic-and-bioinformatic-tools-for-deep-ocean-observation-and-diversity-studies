## Hands on metabarcoding - beta diversity
## Exercises

## Calculate nMDS

# Use the ASVs_wide_t matrix with the metaMDS() function and call it ASVs_nMDS
ASVs_nMDS <- metaMDS(ASVs_wide_t)

## Prepare aesthetics in a dedicated data frame

# Save aesthetics in beta_env
beta_env <- metadata_clean %>% 
  mutate(Experiment_color = ifelse(Experiment == "Sed002", 
                                   qualitative_colors[1],
                                   qualitative_colors[2])) %>% 
  mutate(Treatment_color = case_when(Treatment == "CTR" ~ greens[1],
                                     Treatment == "Cd 0.015" ~ greens[2],
                                     Treatment == "Cd 0.15" ~ greens[3],
                                     Treatment == "Cd 1.5" ~ greens[4],
                                     Treatment == "Cd 15" ~ greens[5])) %>% 
  mutate(Cd = Concentration)

# Filter metadata for samples that were used
beta_env <- beta_env %>% filter(Sample %in% rownames(seqtab.nochim))

# Add row names to beta_env
# ignore the warning 
rownames(beta_env) <- beta_env$Sample

## Plot nMDS

# Make the default plot with base R, using ASVs_nMDS data
plot(ASVs_nMDS$points, 
     type = "p",
     xlab = "nMDS1",
     ylab = "nMDS2")

# Use points() to edit the points in a new layer of the plot
plot(ASVs_nMDS$points, type = "p",
     xlab = "nMDS1",ylab = "nMDS2")
points(ASVs_nMDS, 
     bg = beta_env$Experiment_color,
     pch = 21, 
     col = "grey", 
     cex = 1)
# Add horizontal and vertical line
abline(h = 0, v = 0)


# Add color legend in top right position
plot(ASVs_nMDS$points, type = "p",
     xlab = "nMDS1",ylab = "nMDS2")
points(ASVs_nMDS, 
       bg = beta_env$Experiment_color,
       pch = 21, col = "grey", 
       cex = 1)
abline(h = 0, v = 0)
legend("topright", 
     legend=c("Sed002", "Sed037"), 
     pch=20, col=qualitative_colors[c(1,2)],cex =1.3)

# Use envfit() to make Cd_fit
Cd_fit <- envfit(ASVs_nMDS ~ Cd, beta_env)

# Add vector fitting
plot(ASVs_nMDS$points, type = "p",
     xlab = "nMDS1",ylab = "nMDS2")
points(ASVs_nMDS, 
       bg = beta_env$Experiment_color,
       pch = 21, col = "grey", 
       cex = 1)
abline(h = 0, v = 0)
plot(Cd_fit)
legend("topright", legend=c("Sed002", "Sed037"), 
       pch=20, col=qualitative_colors[c(1,2)],cex =1.3)

# Add hulls to the previous plot
plot(ASVs_nMDS$points, type = "p",
     xlab = "nMDS1",ylab = "nMDS2")
points(ASVs_nMDS, 
       bg = beta_env$Experiment_color,
       pch = 21, col = "grey", 
       cex = 1)
abline(h = 0, v = 0)
plot(Cd_fit)
legend("topright", legend=c("Sed002", "Sed037"), 
       pch=20, col=qualitative_colors[c(1,2)],cex = 1.3)
with(beta_env,
     ordiellipse(ASVs_nMDS, Experiment, 
                 lty = "dashed", 
                 label = FALSE,
                 cex = 1.3))

# Color points by Treatment instead of Experiment
plot(ASVs_nMDS$points, type = "p",
     xlab = "nMDS1",ylab = "nMDS2", main = "Focus on Treatment")
abline(h = 0, v = 0)
points(ASVs_nMDS, 
       bg = beta_env$Treatment_color,
       pch = 21, col = "grey", 
       cex = 1)
plot(Cd_fit)
legend("topright", legend = unique(beta_env$Treatment), 
       pch=20, col=greens,cex = 1.1)
with(beta_env,
     ordiellipse(ASVs_nMDS, Experiment, 
                 lty = "dashed", 
                 label = TRUE,
                 cex = 1.3))

## PERMANOVA test

# Use betadisper() to test variation in groups to be tested
# Experiment
set.seed(123); permutest(
  betadisper(
    vegdist(ASV_rarefied),
    group = beta_env$Experiment),
  permutations = 999)
# Treatment
set.seed(123); permutest(
  betadisper(
    vegdist(ASV_rarefied),
    group = beta_env$Experiment),
  permutations = 999)


# Calculate PERMANOVA test, using adonis2() function
# Experiment
set.seed(123); adonis2(ASVs_wide_t ~ Experiment, data = beta_env)
# Treatment
set.seed(123); adonis2(ASVs_wide_t ~ Treatment, data = beta_env)
# All combinations of Experiment and Treatment
set.seed(123); adonis2(ASV_rarefied ~ Treatment*Experiment, data = beta_env)

## End


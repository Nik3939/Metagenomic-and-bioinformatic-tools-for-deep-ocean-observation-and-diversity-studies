### Hands on metabarcoding - Import and clean data
### Exercises

## Prepare session

# load packages
____(dplyr) # grammar for data manipulation
____(tidyr) # create tidy data
____(stringr) # manipulate strings
____(ggplot2) # make plots
____(vegan) # diversity analyses
____(ulrb) # for some utils
____(readxl) # read excel files
____(gridExtra) # arrange ggplot2 plots
____(rstatix) # statistics tests

# Vector with qualitative colors
qualitative_colors <- 
  c("#E69F00", "#56B4E9", "#009E73", 
    "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# quantitative scale
greens <- c("grey80", "#C7E9C0","#74C476","#238B45","#00441B")

# For reproducibility 
set.seed(123)

## Import and clean data 

# load DADA2 results
load("./r_objects")

# check variables stored in the environment
ls()

# check class
____(seqtab.nochim)

# check size of rows and columns of seqtab.nochim
____(____)

# check column names
____(____)

## Rarefaction

# 1. check total reads per sample to decide rarefaction threshold
rowSums(____) %>% 
  barplot(col = "steelblue", las = 2)

# 2. Compare: 20 000, 25 000, and 30 000
abline(h = c(____, ____, ____))

# 3. Rarefy to 25000 reads per sample
set.seed(123); ASV_rarefied <- rrarefy(____, sample = ____)

# 4. Verify result 
rowSums(____) %>% 
  ____(col = "steelblue", las = 2)

## More data cleaning

# Turn ASV_rarefied to data.frame format
ASV_rarefied_df <- ____ %>% 
  ____() %>% # switch rows to columns
  ____() # transform into data.frame

# Turn rownames into a column and then remove rownames
ASV_rarefied_df$Sequence <- rownames(____)
rownames(____) <- NULL

# The ASV_ID can be in the form of ASV_1
ASV_rarefied_df$____ <- paste0("ASV_", rownames(____))

## View ASV table
View(ASV_rarefied_df)

## Taxonomy table
taxa

# check dimension size
____(taxa)
# check class
____(____)
# check column names
____

# Put the sequences (in row names) of taxa in a new column, Sequence.
ASV_taxa <- ____ %>% 
  as.data.frame() %>% 
  mutate(____ = rownames(.))

# remove row names 
rownames(____) <- NULL

# Merge the taxonomy and abundance tables, using left_join() by "Sequence"
ASV_combined <- ASV_rarefied_df %>% 
  ____(ASV_taxa, by = ____)

# Merge the taxonomy and abundance tables
ASV_combined <- ASV_rarefied_df %>% 
  left_join(ASV_taxa, by = "Sequence")

# Overview Kingdom level
table(ASV_combined$____)

# Remove organelles, eukaryotes and NAs at phylum level from ASV_combined, if any
ASV_combined_clean <- ____ %>% 
  filter(____ != "Eukarya",
         Order ____ "Chloroplasts",
         Family != "____",
         !is.na(____))

# Verify if unwanted groups were removed
ASV_combined_clean %>% filter(Kingdom ____ "Eukarya")
ASV_combined_clean %>% filter(____ == "Chloroplasts")
ASV_combined_clean %>% filter(____ == "____")
ASV_combined_clean %>% filter(____(Phylum))  

## Metadata 

# Load metadata
metadata <- read_xlsx("./data/FKT_exp_amplicon_map.xlsx")

# see first five rows of metadata
head(____, n = 5)

# Use str() to see the structure of the metadata object
___(____)

# See first five rows of metadata
head(metadata, n = 5)

# Use str() to see the structure of the metadata object
str(metadata)

# Remove unnecessary columns: SampleID, SampleType, Project
metadata.1 <- metadata %>% 
  ____(-SampleID, ____, ____)

# Change variables to correct type
metadata.2 <- metadata.1 %>% 
  mutate(Experiment = as.factor(Experiment),
         Treatment = factor(____,
                            levels = c("CTR", "Cd 0.015", "Cd 0.15", "Cd 1.5", "Cd 15")),
         Replicate = as.factor(____),
         NGS_code = ____(____))

# See the structure of metadata.2
str(metadata.2)

# Add column with concentration values
metadata.3 <- metadata.2 %>% 
  mutate(Concentration = ifelse(Treatment == "CTR", 0, 
                                str_remove(____, "Cd "))) %>%
  # make sure the concentration is numeric
  mutate(Concentration = as.double(____)) 

# Change the name of NGS_code to Sample
colnames(metadata.3)[4] <- "____" 

# For simplicity change the name of the table from metadata.3 to metadata_clean
____ <- ____

## Final merge

# Transform ASV_combined_clean to long format, name it ASVs_long
____ <- ____ %>% 
  pivot_longer(cols = rownames(seqtab.nochim),
               names_to = "Sample",
               values_to = "Abundance")

# Print the first 3 rows of ASVs_long.
____(____, n = 3)

# Add metadata_clean to ASVs_long, using left_join(), by "Sample"
# Call the object ASVs_full
____ <- ____ %>% 
  ____(____, by = ____)

# Filter all values superior to zero in the Abundance column
ASVs_full <- ASVs_full %>% 
  filter(____)

### end
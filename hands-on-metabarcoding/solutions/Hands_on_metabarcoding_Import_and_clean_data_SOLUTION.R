### Hands on metabarcoding - Import and clean data
### Exercises

## Prepare session

# load packageso
library(dplyr) # grammar for data manipulation
library(tidyr) # create tidy data
library(stringr) # manipulate strings
library(ggplot2) # make plots
library(vegan) # diversity analyses
library(ulrb) # for some utils
library(readxl) # read excel files
library(gridExtra) # arrange ggplot2 plots
library(rstatix) 

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
load("r_objects")

# check variables stored in the environment
ls()

# check class
class(seqtab.nochim)

# check size of rows and columns of seqtab.nochim
dim(seqtab.nochim)

# check column names
colnames(seqtab.nochim)

## Rarefaction

# 1. check total reads per sample to decide rarefaction threshold
rowSums(seqtab.nochim) %>% 
  barplot(col = "steelblue", las = 2)

# 2. Compare: 20 000, 25 000, and 30 000
abline(h = c(20000, 25000, 30000))

# 3. Rarefy to 25000 reads per sample
set.seed(123); ASV_rarefied <- rrarefy(seqtab.nochim, sample = 25000)

# 4. Verify result 
rowSums(ASV_rarefied) %>% 
  barplot(col = "steelblue", las = 2)

## More data cleaning

# Turn ASV_rarefied to data.frame format
ASV_rarefied_df <- ASV_rarefied %>% 
  t() %>% # switch rows to columns
  as.data.frame() # transform into data.frame

# Turn rownames into a column and then remove rownames
ASV_rarefied_df$Sequence <- rownames(ASV_rarefied_df)
rownames(ASV_rarefied_df) <- NULL

# The ASV_ID can be in the form of ASV_1
ASV_rarefied_df$ASV_ID <- paste0("ASV_", rownames(ASV_rarefied_df))

## View ASV table
View(ASV_rarefied_df)

## Taxonomy table
taxa

# check dimension size
dim(taxa)
# check class
class(taxa)
# check column names
colnames(taxa)

# Put the sequences (in row names) of taxa in a new column, Sequence.
ASV_taxa <- taxa %>% 
  as.data.frame() %>% 
  mutate(Sequence = rownames(.))

# remove row names 
rownames(ASV_taxa) <- NULL

# Merge the taxonomy and abundance tables, using left_join() by "Sequence"
ASV_combined <- ASV_rarefied_df %>% 
  left_join(ASV_taxa, by = "Sequence")

# Overview Kingdom level
table(ASV_combined$Kingdom)

# Remove organelles, eukaryotes and NAs at phylum level from ASV_combined, if any
ASV_combined_clean <- ASV_combined %>% 
  filter(Kingdom != "Eukarya",
         Order != "Chloroplasts",
         Family != "Mitochondria",
         !is.na(Phylum))

# Verify if unwanted groups were removed
ASV_combined_clean %>% filter(Kingdom == "Eukarya")
ASV_combined_clean %>% filter(Order == "Chloroplasts")
ASV_combined_clean %>% filter(Family == "Mitochondria")
ASV_combined_clean %>% filter(is.na(Phylum))  

## Metadata 

# Load metadata
metadata <- read_xlsx("./data/FKT_exp_amplicon_map.xlsx")

# see first five rows of metadata
head(metadata, n = 5)

# Use str() to see the structure of the metadata object
str(metadata)

# Remove unnecessary columns: SampleID, SampleType, Project
metadata.1 <- metadata %>% 
  select(-SampleID, -SampleType, -Project)
  
# Change variables to correct type
metadata.2 <- metadata.1 %>% 
  mutate(Experiment = as.factor(Experiment),
         Treatment = factor(Treatment,
                            levels = c("CTR", "Cd 0.015", "Cd 0.15", "Cd 1.5", "Cd 15")),
         Replicate = as.factor(Replicate),
         NGS_code = as.factor(NGS_code))

# See the structure of metadata.2
str(metadata.2)

# Add column with concentration values
metadata.3 <- metadata.2 %>% 
  mutate(Concentration = ifelse(Treatment == "CTR", 0, 
                                str_remove(Treatment, "Cd "))) %>%
  # make sure the concentration is numeric
  mutate(Concentration = as.double(Concentration)) 

# Change the name of NGS_code to Sample
colnames(metadata.3)[4] <- "Sample" 

# For simplicity change the name of the table from metadata.3 to metadata_clean
metadata_clean <- metadata.3

## Final merge

# Transform ASV_combined_clean to long format, name it ASVs_long
ASVs_long <- ASV_combined_clean %>% 
  pivot_longer(cols = rownames(seqtab.nochim),
               names_to = "Sample",
               values_to = "Abundance")

# Print the first 3 rows of ASVs_long.
head(ASVs_long, n = 3)

# Add metadata_clean to ASVs_long, using left_join(), by "Sample"
# Call the object ASVs_full
ASVs_full <- ASVs_long %>% 
  left_join(metadata_clean, by = "Sample")

# Filter all values superior to zero in the Abundance column
ASVs_full <- ASVs_full %>% 
  filter(Abundance > 0)

### end

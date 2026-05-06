## DADA2 Pipeline for OMICS 2026 workshop - Metabarcoding hands-on session
## Miguel Semedo
## 05/2026


#### preliminary notes ####


# 1) a lot of # comments on the script (for workshop purposes)

# 2) Some ERRORS PRESENT IN THE SCRIPT as well (Francisco left blank spaces), for exercise purposes. We're going to correct them in the workshop, 
# but BE CAREFUL WHEN USING THE CODE IN THIS SCRIPT to make sure you use corrected versions.

# 3) this will be run on individual machines.

# 4) this script can run in less than 24 hours, just make sure you have 
# R, RStudio, and necessary packages (e.g. dada2) locally installed

# 5) below you can find the code to locally install DADA2, but there's a lot of help online to install any package

# 6) CHECK IF YOU HAVE A METADATA/MAP FILE FOR YOUR SAMPLES AND OPEN A LOG DOC

# 7) I included in the comments some computational time, based on my laptop M4, it may be different in yours.
# But a full processed Rdata file will be provided so that you have access to all intermediate objects produced

#### DADA2 installation - if needed #### 

if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("dada2", version = "3.18")

#### load necessary packages #### 

# load dada2 package
library(dada2); packageVersion("dada2") 

#### Uploading data #### 

# clean up previous run
rm(list=ls()) 

# plots in RStudio window
options(device = "RStudioGD")

# set working directory 
setwd("~/Library/CloudStorage/Dropbox/CIIMAR/TwinDEEPS/Marine_OMICS_workshop/lecture_materials_MS/MS_hands_on_metabarcoding_01")

# check working directory
getwd()

# if you have your script on your working directory location
# you can use RStudio (SHOW)

# locate your files and confirm they're there
# confirm path to the FASTQ reads

raw.files.path <- "FKT_fastq_reads" 
list.files(raw.files.path) 

#### dada2 workflow start #### 

# assign Fwd and Rev files
fnFs <- sort(list.files(raw.files.path, pattern="_1.fastq", full.name = TRUE))
fnFs
fnRs <- sort(list.files(raw.files.path, pattern="_2.fastq", full.names = TRUE))
fnRs

# We just created two objects storing the file names of Fwd and Rev reads
# What type of R object is this (vector, matrix, data.frame, factor)?
# How can you check?

# extract sample names from file name
sample.names <- sapply(strsplit(basename(fnFs), "_"), `[`, 1)
sample.names

# we should have 30 samples, right? can you check if we have all of them? 

# plot quality profiles for each sample (first DADA2 function)
plotQualityProfile(fnFs[01:30], aggregate = F)
plotQualityProfile(fnRs[01:30], aggregate = F) 


# 30 Qplots in the same plot may be too much. Could you plot only a few at a time?

# what do the different lines represent? how would you find out?

# what if we had hundreds of samples?

# But it's important to check every single sample at this stage
# to see if you need to discard some

# How do the samples look?
# Sequences number per sample? (good time to inspect that number as well)

# Place filtered files in filtered/subdirectory
# change "getwd()" to the path where you want to create your filtered reads folder
filt_path <- file.path(getwd(), "filtered_2026") # Place filtered files in filtered subdirectory
filtFs <- file.path(filt_path, paste0(sample.names, "_F_filt.fastq.gz"))
filtRs <- file.path(filt_path, paste0(sample.names, "_R_filt.fastq.gz"))

##### Filtering and trimming #####

# filtering sequences according to Q score and EE (expected errors)
out <- filterAndTrim(fnFs, filtFs, fnRs, filtRs, truncLen = 0, 
                     trimLeft = 0, minLen = 20,
                     maxN=0, minQ = 0, maxEE=c(2,2), truncQ=2,
                     rm.phix=TRUE, compress=TRUE, 
                     multithread=TRUE, verbose = TRUE) # On Windows set multithread=FALSE


# what's the error?


# Are you sure about all the parameters? How to inspect?
# why truncLen = 0?

# When would you change truncLen parameter? 
# expected amplicon size = 400 bp
# what would truncLen=c(240,210) do?
# if you truncate 240 + 210 = 450
# 450 - 400 bp = 50 bo overlap (STILL OK, ~13% of amplicon size)
# minimum recommended overlap of at least 12 bases 
# If you truncate more, you loose overlap (which will decrease merging,
# but increase yield after trimming and chimera removal)
# If you have time, play arround with the truncLen parameter and see how it affects merging and final yield
# What about the primers?
# max EE = 2 for this 250 bp reads represents a maximum of 0.8 % potentially erroneous nucleotides

# INSPECT OUTPUT
head(out) # WANT to see more rows?

##### learning error rates #####

# calibrating error model for denoising
errF <- learnErrors(filtFs, multithread=TRUE) # windows systems -> multithread = FALSE 
errR <- learnErrors(filtRs, multithread=TRUE)

# started at 11:53h. It took 5 mins on my laptop for Fwd
# started at 13:13h It took 5 mins on my laptop for Rev

# ploting error model results
plotErrors(errF, nominalQ=TRUE)
plotErrors(errR, nominalQ=TRUE)

# what are we seeing here? 
# what each plot means?
# what the points, black line, and red line mean?


##### DENOISING (DADA algorithm to find ASVs) #####

# dereplicating sequences before denoising
derepFs <- derepFastq(filtFs, verbose=TRUE)
derepRs <- derepFastq(filtRs, verbose=TRUE)
names(derepFs) <- sample.names
names(derepRs) <- sample.names

# denoising (finding ASVs)
dadaFs <- dada(derepFs, err=errF, multithread=TRUE)
dadaRs <- dada(derepRs, err=errR, multithread=TRUE)
dadaFs[[1]] # checking the number of Fwd ASVs
dadaRs[[1]] # checking the number of Rev ASVs

# Each denoising took 2 mins on my laptop

##### Merging Fwd and Rev reads #####

# merging
mergers <- mergePairs(dadaFs, derepFs, dadaRs, derepRs, verbose=TRUE, maxMismatch = 5)
# ANYTHING WRONG? Any change to the default?


# count the number of reads for each ASV
seqtab <- makeSequenceTable(mergers)
# WHAT IS THIS TABLE?
# number of samples and ASVs
dim(seqtab)
# WHAT'S THE NUMBER OF ASV'S IN THE WHOLE DATASET?
# histogram of sequence length
hist(nchar(getSequences(seqtab)))
# are most sequences around the expected amplicon size?

##### chimera removal #####

seqtab.nochim <- removeBimeraDenovo(seqtab, method="consensus", multithread=TRUE, verbose=TRUE) 
# took less than 1 minute on my laptop

# number of samples and ASVs without chimeras
dim(seqtab.nochim)
# percentage of non-chimeric reads
sum(seqtab.nochim)/sum(seqtab)
# WHAT's the percentage of sequences/reads removed by chimera removal?
# WHAT'S the percentage of ASVs removed?

##### export an ASV table to a .csv file #####

# export an ASV abundance table
str(seqtab.nochim)
is.matrix(seqtab.nochim)
head(seqtab.nochim)

# Extract ASV table matrix (transpose so that taxa are rows and samples columns)
ASV1 = t(seqtab.nochim)
head(ASV1)
# Coerce to data.frame
ASVdf = as.data.frame(ASV1)
# save file as csv
write.csv(ASVdf, "FKT_exp_ASV_table.csv")

##### Tracking sequence numbers #####

# count sequences after each trimming step
getN <- function(x) sum(getUniques(x))
track <- cbind(out, sapply(dadaFs, getN), sapply(mergers, getN), rowSums(seqtab.nochim))

colnames(track) <- c("input", "filtered", "denoised", "merged", "nonchim")
rownames(track) <- sample.names
head(track)

# exporting "tracking table" - important for downstream analysis and for reporting results
write.csv(track, file="FKT_exp_track.csv")

# open track.csv file in excel and calculate what's the average percent of final reads in relation to raw reads
# what's the minimum, mean, and maximum number of reads per sample?
# Is it OK to you?

##### Taxonomic assignment #####

taxa <- assignTaxonomy(seqtab.nochim, "silva_nr99_v138.1_train_set.fa", multithread=TRUE)
# which reference database are we using here?

# Took 2 minutes on my laptop

# if you try different reference databases, how would you name the taxa R object?

# export taxonomic table
write.csv(taxa, file="FKT_exp_taxa_v138.csv")

# saving seqtab.nochim and taxa as R objects to upload them if neede for downstream analysis in R
# for use in phyloseq, vegan, etc. (phyloseq, vegan,)
save(seqtab.nochim, taxa, file = "dada2_FKT_exp_output.RData")

# This is the end of the DADA2 upstream analysis
# Important outputs:
# - ASV abundance table (seqtab.nochim)
# - Taxa table (taxa)
# - Track table (track)
# All these outputs were exported as .csv while seqtab.nochim and taxa were also saved as R objects


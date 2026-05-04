# Install packages
install.packages("dplyr", dependencies = TRUE)
install.packages("tidyr", dependencies = TRUE)
install.packages("stringi", dependencies = TRUE)
install.packages("stringr", dependencies = TRUE)
install.packages("ggplot2", dependencies = TRUE)
install.packages("vegan", dependencies = TRUE)
install.packages("ulrb", dependencies = TRUE)
install.packages("readxl", dependencies = TRUE)
install.packages("ggVennDiagram", dependencies = TRUE)

# Install DADA2 (https://benjjneb.github.io/dada2/dada-installation.html)
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("dada2", version = "3.22") # note: you may need to change version depending on your R version (this one works for R 4.5)

# if this doesn't work check the tutorial page for other install options

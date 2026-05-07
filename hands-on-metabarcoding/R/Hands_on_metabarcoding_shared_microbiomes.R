#
# Explore shared microbiome between conditions
library(ggVennDiagram)

#
ctr_asvs <- ASVs_full %>% filter(Treatment == "CTR") %>% pull(Sequence)
#
cd_15_asvs <- ASVs_full %>% filter(Treatment == "____") %>% pull(Sequence)

#
ggVennDiagram(x = list(ctr_asvs, # group 1
                       cd_15_asvs), # group 2
              category.names = c("CTR",
                                 "Cd 15"),
              label_size = 4) + 
  scale_fill_gradient(low = "#F4FAFE", high = "#4981BF") +
  guides(fill = "none") + 
  xlim(-6,9) +
  ylim(-5,10)

# try all treatments
cd_0.015_asvs <- ASVs_full %>% filter(____ == ____) %>% pull(___)
cd_0.15_asvs <- ASVs_full %>% filter(____ == ____) %>% pull(Sequence)
cd_1.5_asvs <- ASVs_full %>% filter(____ == ____) %>% pull(Sequence)

# may take some time to plot
ggVennDiagram(x = list(____,
                       ____, 
                       ____,
                       ____,
                       ____), 
              category.names = c("CTR (0 \U03BCM)",
                                 "Cd 0.015 \U03BCM",
                                 "Cd 0.15 \U03BCM",
                                 "Cd 1.5 \U03BCM",
                                 "Cd 15 \U03BCM"),
              label_size = 4) + 
  #scale_fill_gradient(low = "#F4FAFE", high = "#4981BF") +
  guides(fill = "none") 

#


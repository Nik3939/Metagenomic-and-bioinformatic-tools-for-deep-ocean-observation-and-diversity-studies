## R tools for microbial ecology
## Exercises

# Print number 1
1

# This is a comment

# Make an object 
a <- 1
a

# R does not know what b means
b
# but you can print the string "b"
"b"

# Logical symbols
a <- 1
a == 1
a > 0
a != 1


## Error vs warning

# Error example
dog
# Solution to error
"dog"

# Warning example
as.numeric(c(1, 2, "three"))

# Warning solution
as.numeric(c(1, 2, 3))

## Types of objects

# Atomic vector examples
1
1:10
c("Male", "Female", "Male", "Female")
c(TRUE, FALSE, TRUE)

# Matrix example
matrix(c(1:10), nrow = 4, ncol = 5)

# Example of data.frame
data.frame(
  col1 = 1:4,
  gender = c("Female", "Male", "Female", "Female"),
  Truth = c(TRUE, FALSE, TRUE, TRUE)
)

# Example of a list
list(
  c(TRUE, FALSE, TRUE),
  data.frame(Col1 = 1:3,
             gender = c("Male", "Female", "Male")
  )
)

## Factor vs character

# make a factor variable
gender_factor <- factor(c("Male", "Female"))
# make a character variable
gender_character <- c("Male", "Female")
# they provide the same information
gender_factor == gender_character
# but they are of different class
class(gender_factor) == class(gender_character)
# a factor attributes a number to a character
typeof(gender_factor)
typeof(gender_character)

## Indexing and subseting

# make a data frame
a <- data.frame(a = 1:4, b = letters[1:4])
# select the second line of the b column
a[2, "b"]


## Base R plots

# set a device for 4 figures
par(mfrow = c(1,3))
plot(x = 0:10, y = 20:10, main = "Plot")
barplot(height = 1:10, main = "Barplot")
hist(rnorm(200, mean= 10, sd = 5), breaks = 30)

# Improve histogram
dev.off()
hist(rnorm(200, mean= 10, sd = 5), 
     breaks = 30,
     col = "steelblue",
     main = "Histogram of random normal distribution",
     xlab = "Value",
     ylab = "Frequency")

## Function in R 

# Make function, addx, that does x + x
addx <- function(x){
  a = x + x
  return(a)
}

# Examples of application
addx
addx(1)
addx(x = 20)

# See arguments of mean()
args(mean)

## R packages
# To install
#install.packages("dplyr")
# To load into session
library(dplyr)

## dplyr

# Data from dplyr
starwars

# Filter human characters
starwars %>%
  filter(species == "Human") 

# Select name, height, gender and species columns
starwars %>%
  select(name, height, gender, species)

# Change the height from centimeters to meters
starwars %>%
  mutate(height = height/100)

# Combine the previous steps in a single line of code
starwars %>% 
  filter(species == "Human") %>% 
  select(name, height, gender, species) %>% 
  mutate(height = height/100)


## ggplot2

# Load ggplot2 into session
library(ggplot2)

# ggplot example
starwars %>%
  filter(species == "Human", !is.na(height)) %>%
  select(name, height, gender, species) %>%
  mutate(height = height/100) %>%
  ggplot(aes(x = reorder(name, height), 
             y = height, fill = gender)) +
  geom_col() +
  theme_bw() +
  theme(panel.grid = element_blank(), 
        legend.position = "top") + 
  labs(fill = "gender:", 
       y = "height (m)", x = "Character") +
  coord_flip()

## end

## Wenzhong Zhang
## Email: Wenzhong.Zhang@helsinki.fi
## 11th November 2017
## Data wrangling for final project
## The Human Developement (HD) and Gender Inequality Index (GII) data were joined by the country name, the incomplete data filtered out, and the ratio of education completeness added as a new column. The level of hdi was categorized into four degrees (low, medium, high and very high) according to the description. Some unnecessary data (related to the hypothesis) was removed from the data. 

# access the dplyr, tidyr, ggplot2 and stringr library
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# read the dataset
hd <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/human_development.csv", stringsAsFactors = F)
gii <- read.csv("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/gender_inequality.csv", stringsAsFactors = F, na.strings = "..")

# explore the structure and dimensions of the data
str(hd)
str(gii)
dim(hd)
dim(gii)

# change the column names into easier and readable format
colnames(hd) <- c("hdir", "cty", "hdi", "lifebirth", "edutime", "meanedu", "gni", "gnirhdir")
colnames(gii) <- c("giir", "cty", "gii", "mortalityM", "teenbirth", "ParF", "edu2F", "edu2M", "labF", "labM")

# check the change
summary(hd)
summary(gii)

# the two data sets are to be joined by "country" name
# common columns to use as identifiers
join_by <- c("cty")

# join the two datasets by the selected identifiers
human <- inner_join(hd, gii, by = join_by)

# explore the structure and dimensions of the data
str(human)
dim(human)
glimpse(human)

# columns to keep
keep <- c("cty", "hdi", "lifebirth", "edutime", "meanedu", "gni", "gnirhdir", "teenbirth", "edu2F", "edu2M", "labF", "labM")

# select the 'keep' columns
human <- select(human, one_of(keep))

# explore the structure and dimensions of the data
str(human)
dim(human)
glimpse(human)

# print out a completeness indicator of the 'human' data
complete.cases(human)

# print out the data along with a completeness indicator as the last column
data.frame(human[-1], comp = complete.cases(human))

# filter out all rows with NA values
human_ <- filter(human, complete.cases(human) == TRUE)

# define a new column representing the ratio of the mean completeness of education
human_ <- mutate(human_, meaneduratio = meanedu / edutime)

# define a new logical column 'teenbirth_high'
human_ <- mutate(human_, teenbirth_high = teenbirth > 33)

# remove the commas from gni
human_ <- within(human_, {
  gni <- as.character(gni)
})
human_ <- within(human_, {
  gni <- as.numeric(sub(",", "", gni, fixed = TRUE))
})

# create a vector to separate different degrees of human development according to definition
sep <- c(0.348, 0.55, 0.699, 0.799, 0.944)

# create a categorical variable 'crime'
hdi_d <- cut(human_$hdi, breaks = sep, include.lowest = TRUE, labels = c("low", "med", "high", "very_high"))

# add the new categorical value to scaled data
human_ <- data.frame(human_, hdi_d)

# add countries as rownames
rownames(human_) <- human_$cty

# remove the Country variable
human_ <- dplyr::select(human_, -cty)

# explore the structure and dimensions of the data
str(human_)
dim(human_)
glimpse(human_)
summary(human_)

# Saving the analysis daatset, name it as human.txt, under the data folder
write.table(human_, file = "Data/human.txt")



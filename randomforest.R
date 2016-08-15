# =============================================== #
# Random forest analysis on Reggio variables      
# Date: 2016/08/15
# Author: Jessica Yu Kyung Koh
# =============================================== #
# Use necessary libraries
install.packages('randomForest')
install.packages('readstata13')
library(foreign)
library(randomForest)
library(readstata13)

# Set environment variables
klmReggio   <- Sys.getenv("klmReggio")
data_reggio <- Sys.getenv("data_reggio")
git_reggio  <- Sys.getenv("git_reggio")

# Bring in data
reggiodata <- read.dta13("Z:/SURVEY_DATA_COLLECTION/data/Reggio_prepared.dta")


# Run random forest command
set.seed(1)

fit <- randomForest(as.factor(Survived) ~ Pclass + Sex + Age + SibSp + Parch + Fare +
                     Embarked + Title + FamilySize + FamilyID2,
                   data=train, 
                   importance=TRUE, 
                   ntree=2000)
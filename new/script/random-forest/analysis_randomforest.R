# =============================================== #
# Random forest analysis on Reggio variables      
# Date: 2016/08/15
# Author: Jessica Yu Kyung Koh
# =============================================== #

# Note: 'randomForest' package doesn't have any in-built way for plotting the trees
#       'party' and 'tree' packages plot trees.

# Use necessary libraries
#install.packages('foreign')
#install.packages('randomForest')
#install.packages('readstata13')
#install.packages('tree')
#install.packages('party')
library(foreign)
library(randomForest)
library(readstata13)
library(tree)
library(party)
library(rpart)


# Set environment variables
klmReggio   <- Sys.getenv("klmReggio")
data_reggio <- Sys.getenv("data_reggio")
git_reggio  <- Sys.getenv("git_reggio")


# Bring in data
dirdata <- file.path(data_reggio, "Reggio_prepared.dta")
reggiodata <- read.dta13(dirdata)


# Locals for random forest input
outcomes_of_interest	<- c("BMIcat")	
#outcomes_of_interest	<- c("BMI_obese", "BMI_overweight", "MaxEdu", "IQ_factor")	
#explanatory_var	<- c("City", "Cohort", "maternaType", "Male", "cgMigrant", "cgCatholic", "int_cgCatFaith", "cgIncomeCat", "momMaxEdu", "dadMaxEdu", "numSiblings")	
#explanatory_var	<- c("City", "Cohort", "maternaType")		
explanatory_var <-c("BornCity", "cgIncomeCat", "cgRelig", "City", "Cohort", "maternaType")


# Use tree package to see the classification
for (i in outcomes_of_interest) {
  plot.new()
  # Make formula
  fmla <- paste(i, paste(explanatory_var, collapse = " + "), sep = " ~ ")
  
  # Run tree and save the plot
  print("Running tree")
  trnew = rpart(MaxEdu ~ Male + cgMigrant + cgCatholic + cgRelig +  City + Cohort + maternaType, data = reggiodata, 
                method = "class", cp = 0.002) 
  
  print("Saving plots")
  png(filename = file.path(git_reggio, "Output", "Randomforest", "MaxEdu_R.png"),width = 1500,height = 1200)
  plot(trnew); text(trnew, cex = 2)
  dev.off()
  
}

plot.new()

# Run tree and save the plot
print("Running tree")
trbmi = rpart(BMIcat ~ Male + cgMigrant + cgCatholic + cgRelig + + momMaxEdu + dadMaxEdu + City + Cohort + maternaType, data = reggiodata, 
              method = "class", cp = 0) 

print("Saving plots")
png(filename = file.path(git_reggio, "Output", "Randomforest", "BMIcat_R.png"),width = 1500,height = 1200)
plot(trbmi); text(trbmi, cex = 2)
dev.off()



plot.new()

# Run tree and save the plot
print("Running tree")
triq = rpart(IQ_factor ~ Male + cgMigrant + cgCatholic + cgRelig + momMaxEdu + dadMaxEdu + City + Cohort + maternaType, data = reggiodata, 
              method = "class", cp = 0.003) 

print("Saving plots")
png(filename = file.path(git_reggio, "Output", "Randomforest", "IQfactor_R.png"),width = 1500,height = 1200)
plot(triq); text(triq, cex = 2)
dev.off()

# Use random forest package
#set.seed(1)

#for (i in outcomes_of_interest) {
#  fit <- randomForest(as.factor(i) ~ fml,
#                     data = reggiodata, 
#                     importance=TRUE, 
#                     ntree=10)
#}


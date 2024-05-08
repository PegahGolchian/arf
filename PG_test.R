# Try Sample several times and average
# SScript for debugging to understand the code

#devtools::install_github("imbs-hl/ranger", ref= "missing_values")
library(ranger)

#library("foreach")
#library(dplyr)
library(doParallel)
#source("Mean_Median_Mode_Imputation.R")
library(arf)
library(missMethods)

#preHandling = "median",
parallel= FALSE
alpha= 1e-10
par = 1
feature_names <-colnames(iris)

iris_na <- iris

iris_na <- delete_MCAR(iris, 0.2, cols_mis =  feature_names )

iris_na[1,1] <- NA
iris_na[1,2] <- NA
iris_na[2,1] <- NA
iris_na[2,5] <- NA
iris_na[50,5] <- NA
iris_na[51,5] <- NA

dataset <- iris_na

data_input <-dataset#dataset[complete.cases(dataset), ]

cond <- which(!complete.cases(dataset))
cond_na <- dataset[!complete.cases(dataset), ] 

arf <- adversarial_rf( data_input, parallel= parallel)
psi <- forde(arf, data_input, alpha=alpha, parallel= parallel)
#forge(psi, n_synth = 100, evidence = cond_na, multiple="mean_val_by_n_synth")
x_imputed <- forge(psi, n_synth = 100, evidence = cond_na, multiple="mean_val_by_n_synth")#"no")
#forge(psi, n_synth = 2, evidence = cond_na)#, stepsize = 4)
#TODO: später in impute sample_size -> n_synth in forge, aber in forge machen finde ich immernoch gut.



#chunks <- split(x_imputed, rep(1:ceiling(nrow(x_imputed)/2), each = 2, length.out = nrow(x_imputed)))
#means <- sapply(chunks, function(chunk) mean(chunk$value))
x_imputed
dataset[cond,]<-x_imputed
if(sum(is.na(dataset))!=0){
  warning("We get NAs after imputation")
}
dataset


# Example dataframe
#df <- data.frame(
#  A = c(1, 2, 3),
#  B = c(4, 8, 6),
#  C = c(7, 8, 9)
#)

# Calculate mean of columns for rows 1 to 2
#means <- colMeans(df)#rowMeans(df[1:2, ])
#print(means)
#df

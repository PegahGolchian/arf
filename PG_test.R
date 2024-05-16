# Try Sample several times and average
# SScript for debugging to understand the code

#devtools::install_github("imbs-hl/ranger", ref= "missing_values")
library(ranger)

library(doParallel)
library(arf)
library(missMethods)
library(missForest)

seed= 123

parallel= FALSE
alpha= 1e-10
par = 1
feature_names <-colnames(iris)

iris_na <- iris

#iris_na <- delete_MCAR(iris, 0.2, cols_mis =  feature_names )

iris_na[1,1] <- NA
iris_na[1,2] <- NA
iris_na[2,1] <- NA
iris_na[2,5] <- NA
iris_na[50,5] <- NA
iris_na[51,5] <- NA

dataset <- iris_na

data_input <-dataset[complete.cases(dataset), ]

cond <- which(!complete.cases(dataset))

cond_na <- dataset[!complete.cases(dataset), ] 

arf <- adversarial_rf( data_input, parallel= parallel)
psi <- forde(arf, data_input, alpha=alpha, parallel= parallel)
x_imputed <- forge(psi, n_synth = 1, evidence = cond_na, multiple="no_mu")#"mean_val_by_n_synth")#"no")

dataset_mu <- dataset
dataset_mu[cond,]<-x_imputed

columns_with_missing <- colnames(dataset)[colSums(is.na(dataset)) > 0]
for (col in columns_with_missing) {
  dataset[[col]][is.na(dataset[[col]])] <- dataset_mu[[col]][is.na(dataset[[col]])] 
}

iris_na[cond,]
dataset[cond,]
x_imputed <- missForest(iris_na)

#dataset[cond,]<-x_imputed
#dataset[cond,]
iris[cond,]

dataset <- 

if(sum(is.na(dataset))!=0){
  warning("We get NAs after imputation")
}
head(dataset)
head(iris)

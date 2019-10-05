## ---- include = FALSE----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup, cache=TRUE---------------------------------------------------
suppressPackageStartupMessages(library(disk.frame))

if(interactive()) {
  setup_disk.frame() 
} else {
  # only use 1 work to pass CRAN check
  setup_disk.frame(1)
}


## ----glm, cache=TRUE-----------------------------------------------------
m = glm(dist ~ speed, data = cars)

## ---- depeondson='glm'---------------------------------------------------
summary(m)

## ---- depeondson='glm'---------------------------------------------------
broom::tidy(m)

## ----dependson='setup'---------------------------------------------------
cars.df = as.disk.frame(cars)

m = dfglm(dist ~speed, cars.df)

summary(m)

broom::tidy(m)

## ----dependson='setup'---------------------------------------------------
iris.df = as.disk.frame(iris)

# fit a logistic regression model to predict Speciess == "setosa" using all variables
all_terms_except_species = setdiff(names(iris.df), "Species")
formula_rhs = paste0(all_terms_except_species, collapse = "+")

formula = as.formula(paste("Species == 'versicolor' ~ ", formula_rhs))

iris_model = dfglm(formula , data = iris.df, family=binomial())

# iris_model = dfglm(Species == "setosa" ~ , data = iris.df, family=binomial())

summary(iris_model)

broom::tidy(iris_model)


# Installation des packages
if (!require(rmarkdown)){install.packages("rmarkdown",repos='http://cran.us.r-project.org')}
library(rmarkdown)


file.name <- "cascade_des_couts"
path.to.file <- "W:/01 - Projets/DEV/Cascade"

rmarkdown::render(file.path(path.to.file, paste0(file.name, ".Rmd")))

browseURL( file.path(path.to.file, paste0(file.name, ".html")))

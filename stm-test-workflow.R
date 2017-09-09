# This script implements a test workflow of a structural topic model using the stm R
# package (Roberts et al. 2016). The script incorporates some minor modifications in 
# the original script by Nicholas B. Adams. The link to the source script is found at:  
# https://github.com/nickbadams/D-Lab_TextAnalysisWorkingGroup/tree/master/STM_prep.
# 
# Script modified by: Jose Don T. De Alban
# Date modified:      09 Sept 2017


# ----------------------------------------
# LOAD LIBRARIES
# ----------------------------------------

library(stm)    # Package for sturctural topic modeling
library(igraph) # Package for network analysis and visualisation


# ----------------------------------------
# LOAD DATA
# ----------------------------------------

data <- read.csv("poliblogs2008.csv") # Download link: https://goo.gl/4ohgr4
load("VignetteObjects.RData")         # Download link: https://goo.gl/xK17EQ



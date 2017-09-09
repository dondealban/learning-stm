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

library(stm)      # Package for sturctural topic modeling
library(igraph)   # Package for network analysis and visualisation
library(ggplot2)  # Package for visualisations using Grammar of Graphics

# ----------------------------------------
# LOAD DATA
# ----------------------------------------

data <- read.csv("poliblogs2008.csv") # Download link: https://goo.gl/4ohgr4
load("VignetteObjects.RData")         # Download link: https://goo.gl/xK17EQ

# ----------------------------------------
# PREPARE AND PRE-PROCESS DATA
# ----------------------------------------

# Stemming, stopword removal, etc.
processed <- textProcessor(data$documents, metadata=data)

# Structure and index for usage in the STM model. Ensure that object has no missing
# values. Remove low frequency words using 'lower.thresh' option. See ?prepDocuments 
# for more information.
out <- prepDocuments(processed$documents, processed$vocab, processed$meta)

# The output will have object meta, documents, and vocab 
docs <- out$documents
vocab <- out$vocab
meta <-out$meta

# Take a look at how many words and documents would be removed using different 
# lower.thresholds. Save plot as pdf.
pdf("stm-plot-removed.pdf", width=10, height=8.5)
plotRemoved(processed$documents, lower.thresh=seq(1,200, by=100))
dev.off()

# ----------------------------------------
# ESTIMATE THE STRUCTURAL TOPIC MODEL
# ----------------------------------------

# ESTIMATION WITH THE TOPIC PREVALENCE PARAMETER.
# Run an STM model using the 'out' data with 20 topics. Ask how prevalence of topics 
# varies across documents' meta data, including 'rating' and day. The option 's(day)' 
# applies a spline normalization to 'day' variable. The authors specified the maximum
# number of expectation-maximization iterations = 75, and the seed they are using for 
# reproducibility.
poliblogPrevFit <- stm(out$documents, out$vocab, K=20, prevalence=~rating+s(day), 
                       max.em.its=75, data=out$meta, init.type="Spectral", 
                       seed=8458159)

# ----------------------------------------
# EVALUATE MODELS
# ----------------------------------------

# SEARCH AND SELECT MODEL FOR A FIXED NUMBER OF TOPICS.
# The function 'selectModel' automates the process of finding and selecting a model
# with desirable properties. STM will compare a number of models side by side and will 
# keep the models that do not converge quickly. 
poliblogSelect <- selectModel(out$documents, out$vocab, K=20, prevalence=~rating+s(day),
                              max.em.its=75, data=meta, runs=20, seed=8458159)


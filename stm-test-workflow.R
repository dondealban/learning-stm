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
# The function 'selectModel' assists the user in finding and selecting a model with
# desirable properties in both semantic coherence and exclusivity dimensions (e.g.,
# models with average scores towards the upper right side of the plot). STM will
# compare a number of models side by side and will keep the models that do not 
# converge quickly. 
poliblogSelect <- selectModel(out$documents, out$vocab, K=20, prevalence=~rating+s(day),
                              max.em.its=75, data=meta, runs=20, seed=8458159)

# Plot the different models that make the cut along exclusivity and semantic coherence
# of their topics. Save plot as pdf.
pdf("stm-plot-selected.pdf", width=10, height=8.5)
plotModels(poliblogSelect)
dev.off()

# Each STM has semantic coherence and exclusivity values associated with each topic. 
# The topicQuality' fucntion plots these values and labels each with its topic number.
# Save plot as pdf file.
pdf("stm-plot-topic-quality.pdf", width=10, height=8.5)
topicQuality(model=poliblogPrevFit, documents=docs)
dev.off()

# Select one of the models to work with based on the best semantic coherence and 
# exclusivity values (upper right corner of plot).
selectedModel3 <- poliblogSelect$runout[[3]] # Choose model #3

# Another option is the 'manyTopics' function that performs model selection across
# separate STMs that each assume different number of topics. It works the same as 
# 'selectModel', except user specifies a range of numbers of topics that they want 
# the model fitted for. For example, models with 5, 10, and 15 topics. Then, for 
# each number of topics, 'selectModel' is run multiple times. The output is then 
# processed through a function that takes a pareto dominant run of the model in 
# terms of exclusivity and semantic coherence. If multiple runs are candidates 
# (i.e., none weakly dominates the others), a single model run is randomly chosen 
# from the set of undominated runs.
storage <- manyTopics(out$documents, out$vocab, K=c(7:10), prevalence=~rating+s(day),
                      data=meta, runs=10)
storageOutput1 <- storage$out[[1]] # 7 topics
pdf("stm-plot-storage-output1.pdf", width=10, height=8.5)
plot(storageOutput1)
dev.off()
storageOutput2 <- storage$out[[2]] # 8 topics
pdf("stm-plot-storage-output2.pdf", width=10, height=8.5)
plot(storageOutput2)
dev.off()
storageOutput3 <- storage$out[[3]] # 9 topics
pdf("stm-plot-storage-output3.pdf", width=10, height=8.5)
plot(storageOutput3)
dev.off()
storageOutput4 <- storage$out[[4]] # 10 topics
pdf("stm-plot-storage-output4.pdf", width=10, height=8.5)
plot(storageOutput4)
dev.off()


# ALTERNATIVE: MODEL SEARCH ACROSS A NUMBER OF TOPICS.
# Let R figure out the best model for you defined by exclusivity and semantic 
# coherence for each K (i.e. # of topics). The function 'searchK' uses a data-driven
# approach to selecting the number of topics.
kResult <- searchK(out$documents, out$vocab, K=c(7,10), prevalence=~rating+s(day),
                   data=meta)
pdf("stm-plot-searchk.pdf", width=10, height=8.5)
plot(kResult)
dev.off()




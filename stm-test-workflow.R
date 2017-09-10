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

# Plot the STM using different types. See the proportion of each topic in the entire
# corpus. Save as pdf files.
pdf("stm-plot-prevfit.pdf", width=10, height=8.5)
plot(poliblogPrevFit)
dev.off()
pdf("stm-plot-prevfit-summary.pdf", width=10, height=8.5)
plot(poliblogPrevFit, type="summary", xlim=c(0,.4))
dev.off()
pdf("stm-plot-prevfit-labels.pdf", width=10, height=8.5)
plot(poliblogPrevFit, type="labels", topics=c(3,7,20))
dev.off()
pdf("stm-plot-prevfit-histogram.pdf", width=14, height=12.5)
plot(poliblogPrevFit, type="hist")
dev.off()

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
# of their topics. Save plot as pdf file.
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
# from the set of undominated runs. Save plots as pdf files.
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
# approach to selecting the number of topics. Save plot as pdf file.
kResult <- searchK(out$documents, out$vocab, K=c(7,10), prevalence=~rating+s(day),
                   data=meta)
pdf("stm-plot-searchk.pdf", width=10, height=8.5)
plot(kResult)
dev.off()

# ----------------------------------------
# INTERPRET STMs BY PLOTTING RESULTS
# ----------------------------------------

# According to the package vignette, there are a number of ways to interpret the model
# results. These include:
# 1. Displaying words associated with topics: labelTopics, sageLabels
# 2. Displaying documents highly associated with particular topics: findThoughts
# 3. Estimating relationships between metadata and topics: estimateEffect
# 4. Estimating topic correlations: topicCorr

# LABELTOPICS.
# Label topics by listing top words for selected topics 3, 7, 20. Save as txt file.
labelTopicsSel <- labelTopics(poliblogPrevFit, c(3,7,20))
sink("stm-list-label-topics-selected.txt", append=FALSE, split=TRUE)
print(labelTopicsSel)
sink()
# Label topics by listing top words for all topics. Save as txt file.
labelTopicsAll <- labelTopics(poliblogPrevFit, c(1:20))
sink("stm-list-label-topics-all.txt", append=FALSE, split=TRUE)
print(labelTopicsAll)
sink()

# SAGELABELS.
# This can be used as a more detailed alternative to labelTopics. The function displays
# verbose labels that describe topics and topic-covariate groups in depth.
sink("stm-list-sagelabel.txt", append=FALSE, split=TRUE)
print(sageLabels(poliblogPrevFit))
sink()

# FINDTHOUGHTS.
# Read documents that are highly correlated with the user-specified topics using the 
# findThoughts() function.

# Object 'thoughts1' contains 3 documents about topic 1 and 'texts=shortdoc' gives
# just the first 250 words. Additional examples are done for topics 3,7,10, and 20.
thoughts1 <- findThoughts(poliblogPrevFit, texts=shortdoc, n=3, topics=1)$docs[[1]]
pdf("stm-plot-find-thoughts1.pdf", width=10, height=8.5)
plotQuote(thoughts1, width=40, main="Topic 1")
dev.off()
thoughts3 <- findThoughts(poliblogPrevFit, texts=shortdoc, n=3, topics=3)$docs[[1]]
pdf("stm-plot-find-thoughts3.pdf", width=10, height=8.5)
plotQuote(thoughts3, width=40, main="Topic 3")
dev.off()
thoughts7 <- findThoughts(poliblogPrevFit, texts=shortdoc, n=3, topics=7)$docs[[1]]
pdf("stm-plot-find-thoughts7.pdf", width=10, height=8.5)
plotQuote(thoughts7, width=40, main="Topic 7")
dev.off()
thoughts10 <- findThoughts(poliblogPrevFit, texts=shortdoc, n=3, topics=10)$docs[[1]]
pdf("stm-plot-find-thoughts10.pdf", width=10, height=8.5)
plotQuote(thoughts10, width=40, main="Topic 10")
dev.off()
thoughts20 <- findThoughts(poliblogPrevFit, texts=shortdoc, n=3, topics=20)$docs[[1]]
pdf("stm-plot-find-thoughts20.pdf", width=10, height=8.5)
plotQuote(thoughts20, width=40, main="Topic 20")
dev.off()

# Learning Structural Topic Modeling
This is a repository set up as my personal exercise for learning structural topic modeling, a method utilising machine learning techniques for automated content analysis of textual data.  

## What is a Structural Topic Model?
A Structural Topic Model is a general framework for topic modeling with document-level covariate information, which can improve inference and qualitative interpretability by affecting topical prevalence, topic content, or both [(Roberts et al. 2016)](#roberts_etal_2016). The goal of the Structural Topic Model is to allow researchers to discover topics and estimate their relationships to document metadata where the outputs of the models can be used for hypothesis testing of these relationships. The [`stm`](http://www.structuraltopicmodel.com) R package implements the estimation algorithms for the model and includes tools for every stage of a standard workflow including model estimation, summary, and visualisation.

## Materials
To learn and understand a typical workflow of structural topic modeling using the `stm` R package [(Roberts et al. 2017)](#roberts_etal_2017), I followed the instructions from the `stm` package [vignette](https://github.com/bstewart/stm/blob/master/inst/doc/stmVignette.pdf?raw=true), which contains a short technical overview of structural topic models and a demonstration of the basic usage of the package through examples of the functions used in a typical workflow. Also, I referred to the scripts from Nick B. Adams' [D-Lab Text Analysis Working Group](https://github.com/nickbadams/D-Lab_TextAnalysisWorkingGroup) with some additions for this learning exercise.

## Dataset
The dataset used to illustrate the `stm` package, as used in the vignette, is a collection of blogposts about American politics written in 2008 put together by the Carnegie Mellon University 2008 Political Blog Corpus [(Eisenstein & Xing 2010)](#eisenstein_xing_2010). 
I copied the dataset into this repository for easier replication. The original links to the example datasets can be found in the vignette and in the R script. 

## An `stm` Workflow Example
I implemented the following workflow for generating structural topic models in R software. Note that this workflow follows the steps outlined in the vignette so I can explore most of the `stm` functions and see how to implement them. Users can modify this to suit their objectives.


### A. Ingest

The following R packages or libraries were used for this exercise: `stm`, `stmCorrViz`, and `igraph`. To load these packages we can write:
```R
library(stm)        # Package for sturctural topic modeling
library(igraph)     # Package for network analysis and visualisation
library(stmCorrViz) # Package for hierarchical correlation view of STMs
```

As described above, the dataset used include a CSV file (poliblogs2008.csv) and an RData file (VignetteObjects.RData), which contains a pre-processed texts by the package authors named 'shortdoc' that was used for their vignette example. Having the RData file can be used to reduce compiling time by not running the models and instead load a workspace with the models already estimated. (Note these source links to the [CSV](https://goo.gl/4ohgr4) and [RData](https://goo.gl/xK17EQ) files.)
```R
data <- read.csv("poliblogs2008.csv") 
load("VignetteObjects.RData") 
```

### B. Prepare

For data preparation, first, stemming and stopword removal were done using the `textProcessor()` function:
```R
processed <- textProcessor(data$documents, metadata=data)
```

Then, `prepDocuments()` was used to structure and index the data for usage in the structural topic model. The object should have no missing values. Low frequency words can be removed using the 'lower.thresh' option. See `?prepDocuments` for more information.
```R
out <- prepDocuments(processed$documents, processed$vocab, processed$meta)
```

Next, save the output object meta, documents, and vocab into variables:
```R
docs <- out$documents
vocab <- out$vocab
meta <- out$meta
```

To check how many words and documents would be removed using different lower thresholds, `plotRemoved()` can be used:
```R
plotRemoved(processed$documents, lower.thresh=seq(1,200, by=100))
```

*Plot of the documents, words, and tokens removed using the specified threshold*
![plotRemoved](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-removed.png)

### C. Estimate

Next, estimate the structural topic model with the topic prevalence parameter. To do this, execute an `stm` model using the 'out' data with 20 topics. Here we can ask how prevalence of topics varies across documents' meta data, including 'rating' and 'day'. The option 's(day)' applies a spline normalization to 'day' variable. The `stm` R package authors specified the maximum number of expectation-maximization iterations = 75, and the seed they used for reproducibility.
```R
poliblogPrevFit <- stm(out$documents, out$vocab, K=20, prevalence=~rating+s(day), 
                       max.em.its=75, data=out$meta, init.type="Spectral", 
                       seed=8458159)
```

The model can then be plotted in different types such as:

*The summary model with 20 topics*
```R
plot(poliblogPrevFit, type="summary", xlim=c(0,.4))
```
![prevfit-summary](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit.png)

*The most frequent words in the model such as for topics #3, #7, and #20*
```R
plot(poliblogPrevFit, type="labels", topics=c(3,7,20))
```
![prevfit-labels](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit-labels.png)

*The histograms of topics*
```R
plot(poliblogPrevFit, type="hist")
```
![prevfit-hist](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit-histogram.png)

*A comparison of two topics such as topics #7 and #10*
```R
plot(poliblogPrevFit, type="perspectives", topics=c(7,10))
```
![prevfit-hist](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit-perspectives-two-topic.png)

### D. Evaluate

##### Search and select model for a fixed number of topics
The function `selectModel()` assists the user in finding and selecting a model with desirable properties in both semantic coherence and exclusivity dimensions (e.g., models with average scores towards the upper right side of the plot). STM will compare a number of models side by side and will keep the models that do not converge quickly. 
```R
poliblogSelect <- selectModel(out$documents, out$vocab, K=20, prevalence=~rating+s(day),
                              max.em.its=75, data=meta, runs=20, seed=8458159)
```

Each STM has semantic coherence and exclusivity values associated with each topic. Plotting the different models that make the cut along exclusivity and semantic coherence of their topics would show:
```R
plotModels(poliblogSelect)
```
![plot-selected](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-selected.png)

The `topicQuality()` function plots these values and labels each with its topic number:
```R
topicQuality(model=poliblogPrevFit, documents=docs)
```
![plot-topicquality](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-topic-quality.png)

Next, select one of the models to work with based on the best semantic coherence and exclusivity values (upper right corner of plot), which in this case can be #3. Selecting this model can be done by:
```R
selectedModel3 <- poliblogSelect$runout[[3]] # Choose model #3
```

Another option is the `manyTopics()` function that performs model selection across separate STMs that each assume different number of topics. It works the same as `selectModel()`, except that the user specifies a range of numbers of topics for fitting the model. For example, models with 5, 10, and 15 topics. Then, for each number of topics, selectModel() is run multiple times. The output is then processed through a function that takes a pareto dominant run of the model in terms of exclusivity and semantic coherence. If multiple runs are candidates (i.e., none weakly dominates the others), a single model run is randomly chosen from the set of undominated runs. 
```R
storage <- manyTopics(out$documents, out$vocab, K=c(7:10), prevalence=~rating+s(day),
                      data=meta, runs=10)
storageOutput1 <- storage$out[[1]] # For example, choosing the model with 7 topics
plot(storageOutput1)
```
![plot-manytopics](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-storage-output1.png)

##### Model search across a number of topics 
Alternatively, R can be instructed to figure out the best model automatically defined by exclusivity and semantic coherence for each K (i.e. # of topics). The `searchK()` function uses a data-driven approach to selecting the number of topics. 
```R
kResult <- searchK(out$documents, out$vocab, K=c(7,10), prevalence=~rating+s(day),
                   data=meta)
plot(kResult)
```
![plot-searchk](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-searchk.png)

### E. Understand

According to the package vignette, there are a number of ways to interpret the model results. These include:
- Displaying words associated with topics: `labelTopics()`, `sageLabels()`
- Displaying documents highly associated with particular topics: `findThoughts()`
- Estimating relationships between metadata and topics: `estimateEffect()`
- Estimating topic correlations: `topicCorr()`





...to be continued...

## References

<a name="eisenstein_xing_2010"></a>
Eisenstein, J., Xing E. (2010) The CMU 2008 Political Blog Corpus. Carnegie Mellon University, Pittsburgh, PA, USA. [(pdf)](http://www.sailing.cs.cmu.edu/main/socialmedia/blog2008.pdf)

<a name="roberts_etal_2016"></a>
Roberts, M.E., Stewart, B.M. & Airoldi, E.M. (2016) A model of text for experimentation in the social sciences. *Journal of the American Statistical Association*, 111, 988–1003. [doi:10.1080/01621459.2016.1141684](http://dx.doi.org/10.1080/01621459.2016.1141684)

<a name="roberts_etal_2017"></a>
Roberts, M.E., Stewart, B.M. Tingley, D. & Benoit, K. (2017) stm: Estimation of the Structural Topic Model. [(https://cran.r-project.org/web/packages/stm/index.html)](https://cran.r-project.org/web/packages/stm/index.html)
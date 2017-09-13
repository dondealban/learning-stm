# Learning Structural Topic Modeling
This is a repository set up as my personal exercise for learning structural topic modeling, a method utilising machine learning techniques for automated content analysis of textual data. It can also be used as a tutorial for someone interested in learning structural topic modeling for their research projects.

## Table of Contents
- [What is a Structural Topic Model?](#stm)
- [Materials](#materials)
- [Dataset](#dataset)
- [An `stm` Workflow Example](#workflow)
    A. [Ingest](#ingest)
    B. [Prepare](#prepare)
    C. [Estimate](#estimate)
    D. [Evaluate](#evaluate)
    E. [Understand](#understand)
    F. [Visualise](#visualise)
- [References](#references)
- [Want to Contribute?](#contribute)

<a name="stm"></a>
## What is a Structural Topic Model?
A Structural Topic Model is a general framework for topic modeling with document-level covariate information, which can improve inference and qualitative interpretability by affecting topical prevalence, topic content, or both [(Roberts et al. 2016)](#roberts_etal_2016). The goal of the Structural Topic Model is to allow researchers to discover topics and estimate their relationships to document metadata where the outputs of the models can be used for hypothesis testing of these relationships. The [`stm`](http://www.structuraltopicmodel.com) R package implements the estimation algorithms for the model and includes tools for every stage of a standard workflow including model estimation, summary, and visualisation.

<a name="materials"></a>
## Materials
To learn and understand a typical workflow of structural topic modeling using the `stm` R package [(Roberts et al. 2017)](#roberts_etal_2017), I followed the instructions from the `stm` package [vignette](https://github.com/bstewart/stm/blob/master/inst/doc/stmVignette.pdf?raw=true), which contains a short technical overview of structural topic models and a demonstration of the basic usage of the package through examples of the functions used in a typical workflow. Also, I referred to the scripts from Nick B. Adams' [D-Lab Text Analysis Working Group](https://github.com/nickbadams/D-Lab_TextAnalysisWorkingGroup) with some additions for this learning exercise.

<a name="dataset"></a>
## Dataset
The dataset used to illustrate the `stm` package, as used in the vignette, is a collection of blogposts about American politics written in 2008 put together by the Carnegie Mellon University 2008 Political Blog Corpus [(Eisenstein & Xing 2010)](#eisenstein_xing_2010). 
I copied the dataset into this repository for easier replication. The original links to the example datasets can be found in the vignette and in the R script. 

<a name="workflow"></a>
## An `stm` Workflow Example
I implemented the following workflow for generating structural topic models in R software. Note that this workflow follows the steps outlined in the vignette so I can explore most of the `stm` functions and see how to implement them. Users can modify this to suit their objectives.

<a name="ingest"></a>
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

<a name="prepare"></a>
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
![plotRemoved](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-removed.png)

<a name="estimate"></a>
### C. Estimate

Next, estimate the structural topic model with the topic prevalence parameter. To do this, execute an `stm` model using the 'out' data with 20 topics. Here we can ask how prevalence of topics varies across documents' meta data, including 'rating' and 'day'. The option 's(day)' applies a spline normalization to 'day' variable. The `stm` R package authors specified the maximum number of expectation-maximization iterations = 75, and the seed they used for reproducibility.
```R
poliblogPrevFit <- stm(out$documents, out$vocab, K=20, prevalence=~rating+s(day), 
                       max.em.its=75, data=out$meta, init.type="Spectral", 
                       seed=8458159)
```

The model can then be plotted in different types such as:

###### The summary model with 20 topics
```R
plot(poliblogPrevFit, type="summary", xlim=c(0,.4))
```
![prevfit-summary](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit.png)

###### The most frequent words in the model such as for topics #3, #7, and #20
```R
plot(poliblogPrevFit, type="labels", topics=c(3,7,20))
```
![prevfit-labels](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit-labels.png)

###### The histograms of topics
```R
plot(poliblogPrevFit, type="hist")
```
![prevfit-hist](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit-histogram.png)

###### A comparison of two topics such as topics #7 and #10
```R
plot(poliblogPrevFit, type="perspectives", topics=c(7,10))
```
![prevfit-hist](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-prevfit-perspectives-two-topic.png)

<a name="evaluate"></a>
### D. Evaluate

###### Search and select model for a fixed number of topics
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

Another option is the `manyTopics()` function that performs model selection across separate STMs that each assume different number of topics. It works the same as `selectModel()`, except that the user specifies a range of numbers of topics for fitting the model. For example, models with 5, 10, and 15 topics. Then, for each number of topics, `selectModel()` is run multiple times. The output is then processed through a function that takes a pareto dominant run of the model in terms of exclusivity and semantic coherence. If multiple runs are candidates (i.e., none weakly dominates the others), a single model run is randomly chosen from the set of undominated runs. 
```R
storage <- manyTopics(out$documents, out$vocab, K=c(7:10), prevalence=~rating+s(day),
                      data=meta, runs=10)
storageOutput1 <- storage$out[[1]] # For example, choosing the model with 7 topics
plot(storageOutput1)
```
![plot-manytopics](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-storage-output1.png)

###### Model search across a number of topics 
Alternatively, R can be instructed to figure out the best model automatically defined by exclusivity and semantic coherence for each K (i.e. # of topics). The `searchK()` function uses a data-driven approach to selecting the number of topics. 
```R
kResult <- searchK(out$documents, out$vocab, K=c(7,10), prevalence=~rating+s(day),
                   data=meta)
plot(kResult)
```
![plot-searchk](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-searchk.png)

<a name="understand"></a>
### E. Understand

According to the package vignette, there are a number of ways to interpret the model results. These include:
- Displaying words associated with topics: `labelTopics()`, `sageLabels()`
- Displaying documents highly associated with particular topics: `findThoughts()`
- Estimating relationships between metadata and topics: `estimateEffect()`
- Estimating topic correlations: `topicCorr()`

An example for `labelTopics()` is by listing top words for selected topics such as for #3, #7, and #20.
```R
labelTopicsSel <- labelTopics(poliblogPrevFit, c(3,7,20))
```
> Topic 3 Top Words:
> 	 Highest Prob: media, news, time, report, stori, show, press
> 	 FREX: oreilli, hanniti, matthew, editor, coverag, journalist, blogger 
> 	 Lift: adolfo, bandwidth, bikini-clad, blogopsher, bmx, bookshelf, broadkorb 
> 	 Score: oreilli, media, rove, fox, matthew, drudg, hanniti 

> Topic 7 Top Words:
> 	 Highest Prob: one, question, hes, even, like, point, doesnt 
> 	 FREX: exit, vis-avi, see-dubya, messiah, barri, itll, maverick 
> 	 Lift: --one, -sahab, advanceupd, ahmadinejad-esqu, al-hanooti, anti-iranian, badass 
> 	 Score: exit, hes, maverick, shes, see-dubya, messiah, gadahn

> Topic 20 Top Words:
> 	 Highest Prob: obama, clinton, campaign, hillari, barack, will, said 
> 	 FREX: clinton, hillari, nafta, obama, wolfson, edward, camp 
> 	 Lift: abcth, ack, amd, argus, asc, bachtel, brawler 
> 	 Score: obama, hillari, clinton, barack, campaign, senat, wolfson 

For `sageLabels()`, this fucntion can be used as a more detailed alternative to `labelTopics()` to display verbose labels that describe topics and topic-covariate groups in depth. An example is shown below for topic #3 out of 20 topics.
```R
print(sageLabels(poliblogPrevFit))
```
> Topic 3: 
> 	 Marginal Highest Prob: media, news, time, report, stori, show, press 
> 	 Marginal FREX: oreilli, hanniti, matthew, editor, coverag, journalist, blogger 
> 	 Marginal Lift: adolfo, bandwidth, bikini-clad, blogopsher, bmx, bookshelf, broadkorb
> 	 Marginal Score: amtak-, boozman, cardoza, crenshaw, granger, herger, ks- 
> 
> 	 Topic Kappa:  
> 	 Kappa with Baseline:  

Using `findThoughts()` function reads documents that are highly correlated with the user-specified topics. Object 'thoughts1' contains 3 documents about topic #3 and 'texts=shortdoc' gives just the first 250 words. 
```R
thoughts3 <- findThoughts(poliblogPrevFit, texts=shortdoc, n=3, topics=3)$docs[[1]]
plotQuote(thoughts3, width=40, main="Topic 3")
```
![plot-findthoughts](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-find-thoughts3.png)

The `estimateEffect()` function explores how prevalence of topics varies across documents according to document covariates (metadata). First, users must specify the variable that they wish to use for calculating an effect. If there are multiple variables specified in `estimateEffect()`, then all other variables are held at their sample median. These parameters include the expected proportion of a document that belongs to a topic as a function of a covariate, or a first difference type estimate, where topic prevalence for a particular topic is contrasted for two groups (e.g., liberal versus conservative).
```R
out$meta$rating <- as.factor(out$meta$rating)
prep <- estimateEffect(1:20 ~ rating+s(day), poliblogPrevFit, meta=out$meta, 
                       uncertainty="Global")
```
To see how prevalence of topics differs across values of a categorical covariate:
```R
plot(prep, covariate="rating", topics=c(3, 7, 20), model=poliblogPrevFit, 
     method="difference", cov.value1="Liberal", cov.value2="Conservative",
     xlab="More Conservative ... More Liberal", main="Effect of Liberal vs. Conservative",
     xlim=c(-.15,.15), labeltype ="custom", custom.labels=c('Obama', 'Sarah Palin', 
                                                          'Bush Presidency'))
```
![plot-est-effect-cat](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-estimate-effect-categorical.png)

To see how prevalence of topics differs across values of a continuous covariate:
```R
plot(prep, "day", method="continuous", topics=20, model=z, printlegend=FALSE, xaxt="n", 
     xlab="Time (2008)")
monthseq <- seq(from=as.Date("2008-01-01"), to=as.Date("2008-12-01"), by="month")
monthnames <- months(monthseq)
axis(1, at=as.numeric(monthseq)-min(as.numeric(monthseq)), labels=monthnames)
```
![plot-est-effect-cont](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-estimate-effect-continuous.png)

Finally, for `topicCorr()` an STM permits correlations between topics. Positive correlations between topics indicate that both topics are likely to be discussed within a document. A graphical network display shows how closely related topics are to one another (i.e., how likely they are to appear in the same document). This function requires `igraph` R package.
```R
mod.out.corr <- topicCorr(poliblogPrevFit)
plot(mod.out.corr)
```
![plot-topiccorr](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-topic-correlations.png)

<a name="visualise"></a>
### F. Visualise

###### Topical content
STM can plot the influence of covariates included in as a topical content covariate. A topical content variable allows for the vocabulary used to talk about a particular topic to vary. First, the STM must be fit with a variable specified in the content option.
```R
poliblogContent <- stm(out$documents, out$vocab, K=20, prevalence=~rating+s(day), 
                       content=~rating, max.em.its=75, data=out$meta, 
                       init.type="Spectral", seed=8458159)
plot(poliblogContent, type="perspectives", topics=7)
```
![plot-content-perspectives](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-content-perspectives.png)

###### Word cloud
```R
cloud(poliblogContent, topic=7)
```
![plot-content-wordcloud](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-content-wordcloud.png)

###### Covariate interactions
Interactions between covariates can be examined such that one variable may “moderate” the effect of another variable.
```R
poliblogInteraction <- stm(out$documents, out$vocab, K=20, prevalence=~rating*day, 
                           max.em.its=75, data=out$meta, seed=8458159)
```
Then, Prep covariates using the `estimateEffect()` function, only this time, we include the interaction variable. 
```R
prep2 <- estimateEffect(c(20) ~ rating*day, poliblogInteraction, metadata=out$meta, 
                        uncertainty="None")
plot(prep2, covariate="day", model=poliblogInteraction, method="continuous", xlab="Days",
     moderator="rating", moderator.value="Liberal", linecol="blue", ylim=c(0,0.12), 
     printlegend=F)
plot(prep2, covariate="day", model=poliblogInteraction, method="continuous", xlab="Days",
     moderator="rating", moderator.value="Conservative", linecol="red", add=T,
     printlegend=F)
legend(0,0.12, c("Liberal", "Conservative"), lwd=2, col=c("blue", "red"))
```
![plot-interact-est-effect](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-plot-interact-estimate-effect.png)

###### Plot convergence
```R
plot(poliblogPrevFit$convergence$bound, type="l", ylab="Approximate Objective", 
     main="Convergence")
```

###### Interactive visualisation
Finally, the `stmCorrViz()` function for the package of the same name generates an interactive visualisation of topic hierarchy/correlations in a structural topicl model. The package performs a hierarchical clustering of topics that are then exported to a JSON object and visualised using D3.
```R
stmCorrViz(poliblogPrevFit, "stm-interactive-correlation.html", 
           documents_raw=data$documents, documents_matrix=out$documents)
```
To see the results, open the [HTML](https://github.com/dondealban/learning-stm/blob/master/outputs/stm-interactive-correlation.html) file output on a browser.

<a name="references"></a>
## References

<a name="eisenstein_xing_2010"></a>
Eisenstein, J., Xing E. (2010) The CMU 2008 Political Blog Corpus. Carnegie Mellon University, Pittsburgh, PA, USA. [(pdf)](http://www.sailing.cs.cmu.edu/main/socialmedia/blog2008.pdf)

<a name="roberts_etal_2016"></a>
Roberts, M.E., Stewart, B.M. & Airoldi, E.M. (2016) A model of text for experimentation in the social sciences. *Journal of the American Statistical Association*, 111, 988–1003. [doi:10.1080/01621459.2016.1141684](http://dx.doi.org/10.1080/01621459.2016.1141684)

<a name="roberts_etal_2017"></a>
Roberts, M.E., Stewart, B.M. Tingley, D. & Benoit, K. (2017) stm: Estimation of the Structural Topic Model. [(https://cran.r-project.org/web/packages/stm/index.html)](https://cran.r-project.org/web/packages/stm/index.html)

<a name="contribute"></a>
## Want to Contribute?
In case you wish to contribute or suggest changes, please feel free to fork this repository. Commit your changes and submit a pull request. Thanks.
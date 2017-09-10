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
I implemented the following workflow for generating structural topic models in R software. Note that this workflow follows a general outline so I can explore most of the `stm` functions and see how to implement them. Users can modify this to suit their objectives.

###### 1. Load Libraries

The following R packages were used for this exercise: `stm`, `stmCorrViz`, and `igraph`. To load these packages we can write:

```R
library(stm)        # Package for sturctural topic modeling
library(igraph)     # Package for network analysis and visualisation
library(stmCorrViz) # Package for hierarchical correlation view of STMs
```

##### 2. Load Data

As described above, the dataset used include a CSV file (poliblogs2008.csv) and an RData file (VignetteObjects.RData), which contains a pre-processed texts by the package authors named 'shortdoc' that was used for their vignette example. Having the RData file can be used to reduce compiling time by not running the models and instead load a workspace with the models already estimated.

```R
data <- read.csv("poliblogs2008.csv") # Source [(link)](https://goo.gl/4ohgr4)
load("VignetteObjects.RData")         # Source [(link)](https://goo.gl/xK17EQ)
```

## References

<a name="eisenstein_xing_2010"></a>
Eisenstein, J., Xing E. (2010) The CMU 2008 Political Blog Corpus. Carnegie Mellon University, Pittsburgh, PA, USA. [(pdf)](http://www.sailing.cs.cmu.edu/main/socialmedia/blog2008.pdf)

<a name="roberts_etal_2016"></a>
Roberts, M.E., Stewart, B.M. & Airoldi, E.M. (2016) A model of text for experimentation in the social sciences. *Journal of the American Statistical Association*, 111, 988–1003. [doi:10.1080/01621459.2016.1141684](http://dx.doi.org/10.1080/01621459.2016.1141684)

<a name="roberts_etal_2017"></a>
Roberts, M.E., Stewart, B.M. Tingley, D. & Benoit, K. (2017) stm: Estimation of the Structural Topic Model. [(https://cran.r-project.org/web/packages/stm/index.html)](https://cran.r-project.org/web/packages/stm/index.html)
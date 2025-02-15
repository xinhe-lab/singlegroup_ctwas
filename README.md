# ctwas: an R package for integrating molecular QTLs and GWAS for gene discovery

[![R-CMD-check](https://github.com/xinhe-lab/ctwas/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/xinhe-lab/ctwas/actions/workflows/R-CMD-check.yaml)

Expression quantitative trait loci (eQTLs) have often been used to nominate candidate genes from genome-wide association studies (GWAS). However, commonly used methods are susceptible to false positives largely due to linkage disequilibrium (LD) of eQTLs with causal variants acting on the phenotype directly. 

Our method, "causal-TWAS" (cTWAS), addresses this challenge by borrowing ideas from statistical fine-mapping. It is a generalization of methods for transcriptome-wide association studies (TWAS), but when analyzing any gene, it adjusts for other nearby genes *and all nearby genetic variants.*

## Install ctwas

Use "remotes" to install the latest version of ctwas from GitHub: 

```r
install.packages("remotes")
remotes::install_github("xinhe-lab/ctwas",ref = "singlegroup")
```


Currently, ctwas has only been tested on Linux systems.
 
We recommend installing and running ctwas on a high-performance computing system.

## Running ctwas

Running a cTWAS analysis involves four main steps: 

1. Preparing the input data. 

2. Computing associations of genes with the phenotype (Z-scores). 

3. Estimating the model parameters. 

4. Fine-mapping causal genes 

The outputs of cTWAS are posterior inclusion probabilities (PIPs) for all variants and genes.

To learn more about the ctwas R package, we recommend starting with this introductory tutorial: 

[A minimal tutorial of how to run cTWAS without LD](https://xinhe-lab.github.io/singlegroup_ctwas/articles/minimal_tutorial.html) 

To run the full cTWAS, follow these tutorials:
    
- [Preparing input data](https://xinhe-lab.github.io/singlegroup_ctwas/articles/preparing_input_data.html) 

- [Running cTWAS analysis](https://xinhe-lab.github.io/singlegroup_ctwas/articles/ctwas_analysis.html)

- [Summarizing and visualizing cTWAS results](https://xinhe-lab.github.io/singlegroup_ctwas/articles/summarizing_results.html)

- [Post-processing cTWAS results](https://xinhe-lab.github.io/singlegroup_ctwas/articles/postprocessing.html)

In addition, we have some useful functions to help run cTWAS, e.g. for creating your own reference LD data:

- [cTWAS utility functions](https://xinhe-lab.github.io/singlegroup_ctwas/articles/utility_functions.html)

You can [browse source code](https://github.com/xinhe-lab/ctwas/tree/singlegroup) and [report a bug](https://github.com/xinhe-lab/ctwas/issues) here. 

<img style="display:block;margin:auto" width="700" height="300" src="man/figures/workflow.png">

## Citing this work

If you find the `ctwas` package or any of the source code in this
repository useful for your work, please cite:

> Zhao S, Crouse W, Qian S, Luo K, Stephens M, He X. 
> Adjusting for genetic confounders in transcriptome-wide association 
> studies improves discovery of risk genes of complex traits. 
> Nature Genetics 56, 336–347 (2024). 
> https://doi.org/10.1038/s41588-023-01648-9


## Useful resources

We have pre-computed the LD matrices of European samples from UK Biobank. 
They can be downloaded [here](https://uchicago.box.com/s/jqocacd2fulskmhoqnasrknbt59x3xkn). 

We have the lists of reference variant information from all the LD matrices in the genome in [hg38](https://uchicago.box.com/s/t089or92dkovv0epkrjvxq8r9db9ys99) and [hg19](https://uchicago.box.com/s/ufko2gjagcb693dob4khccqubuztb9pz).

cTWAS requires the expression prediction models, or weights, of genes. 
The pre-computed weights of GTEx expression and splicing traits can be downloaded from [PredictDB](https://predictdb.org/post/2021/07/21/gtex-v8-models-on-eqtl-and-sqtl/). 

## Acknowledgments

We thank the authors of `susieR` package for using their codes.

Original `susieR` code obtained by:
```
git clone git@github.com:stephenslab/susieR.git
git checkout c7934c0
```


Minor edits to make it accept different prior variances for each variable.



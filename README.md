# UkraineCrops

## Code and data used to analyse Ukraine grain supply in 2022.

There is a [`UkraineCrops` pkgdown
site](https://mickwelli.github.io/Ukraine-crops/) with vignettes.


## Installation

You can install the `UkraineCrops` package using the command below.

## Authors

Michael Wellington, Australian National University & CSIRO, Email:
<Michael.Wellington@anu.edu.au>

Roger Lawes, CSIRO, Email: <Roger.Lawes@csiro.au>

Petra Kuhnert, CSIRO Data61, Email: <Petra.Kuhnert@data61.csiro.au>


## About the Package

This repo contains all data and code used to analyse Ukraine grain supply in 2022 as outlined in Wellington et al. (2022).  The code appears in three vignettes that outline the NDVI analysis and code for visualising cropland fire area percentages and mapping shipping movements. As the cargo shipping data is very large, we direct readers to the following [download](https://www.emodnet-humanactivities.eu/view-data.php) site, where the data can be downloaded in .tif format. 


## Citation

Wellington et al., (2022). UkraineCrop: an R package housing reproducible code to support a paper that analyses satellite images of cropland in Ukraine to investigate progress of the 2022 season. 

   
   
## References

Wellington, M., Lawes, R., Kuhnert, P. (2022) Rapid monitoring of crop growth, grain exports, and fire patterns in Ukraine, Nature Food, Under Review.
=======
    remotes::install_github(repo = "mickwelli/Ukraine-crops", build_vignettes = TRUE)


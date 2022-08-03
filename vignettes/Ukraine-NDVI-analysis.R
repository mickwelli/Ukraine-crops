## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(knitr)
library(stringr)
library(tidyverse)
library(gratia)
library(mgcv)
library(rgdal)
library(sf)
library(mgcViz)
library(scales)
library(gridExtra)
library(ggsci)
library(itsadug)
library(maps)

## ----echo = TRUE, eval = FALSE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----
#  
#  library(UkraineCrops)
#  data(NDVI_mod_df)
#  data(Ukr_bnds)
#  
#  # Load NDVI data
#  #NDVI_mod_df <- readRDS("./data/NDVI_mod_df.rds")
#  
#  # Load Ukraine bounds
#  #Ukr_bnds <- st_read('./data/Ukr_bnds.rds')
#  
#  # Alternatively, read in shapefile directly
#  #Ukr_bnds <- st_read('./inst/extdata/UKR_adm0.shp')
#  

## ----echo = TRUE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----

# Allocate factor for invasion
NDVI_mod_df$inv <- as.factor(if_else(NDVI_mod_df$date < '2022-02-24', "0", "1"))

## ----echo = TRUE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----

# Setting up the GAM structure with key smoothers for trend terms
all_f <- NDVI ~  
  # smooth term for year
  s(year, bs="cr", k=11) + 
  # cyclic term for season
  s(month, bs="cc", k=12) +  
  # smooth term for space
  s(x,y, bs='gp', k=50)  +            
  # seasonal within year
  ti(month, year, bs = c("cc", "cr"), k = c(12,11)) +  
  # space x time
  ti(x, y, year, d = c(2, 1), bs = c("gp", "cr"), 
     k = c(50,11), m=list(2, NA))  

## ----echo = TRUE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----

# Setting up the GAM structure with an added term reflecting
# the start of the invasion
all_f_inv <- NDVI ~  
  # factor for pre/ post-invasion
  inv + 
  # cyclic term for season
  s(month, bs="cc", k=12, by=inv) +  
  # smooth term for space
  s(x,y, bs='gp', k=50, by=inv) +
  # space x time
  ti(x, y, month, d = c(2, 1), bs = c("gp", "cr"), 
     k = c(50,12), m=list(2, NA), by=inv)  

## ----echo = TRUE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----
all_f_war <- NDVI ~  
  # factor for pre/ post-2022
  war + 
  # cyclic term for season
  s(month, bs="cc", k=12, by=war) +  
  # smooth term for space
  s(x,y, bs='gp', k=50, by=war) +
  # space x time
  ti(x, y, month, d = c(2, 1), bs = c("gp", "cr"), 
     k = c(50,12), m=list(2, NA), by=war) 



## ----echo = TRUE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----

# Run GAMs for large datasets
all_gam <- bam(all_f, data=NDVI_mod_df, discrete=TRUE, nthreads=8, rho=0.8)
all_gam_war <- bam(all_f_war, data=NDVI_mod_df, discrete=TRUE, nthreads=8, rho=0.6)
all_gam_inv <- bam(all_f_inv, data=NDVI_mod_df, discrete=TRUE, nthreads=8, rho=0.6)

# Output shows effect of the invasion on cropland NDVI
summary(all_gam_inv)

## ----echo = TRUE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----

# Get predictions for plotting
all_gam_war_pred <- predict(all_gam_war, se=TRUE)

all_gam_war_pred_df <- data.frame(pred = all_gam_war_pred$fit,
                                  pred_se = all_gam_war_pred$se.fit,
                                  x = NDVI_mod_df$x,
                                  y= NDVI_mod_df$y,
                                  year = NDVI_mod_df$year,
                                  month = NDVI_mod_df$month,
                                  war=NDVI_mod_df$war)


# Filter to current time period to allow comparison of baseline to 2022
all_gam_war_pred_space_df <- all_gam_war_pred_df %>% filter(month < 7)

# Space plot by month
space_month_year_plot <- ggplot(data=all_gam_war_pred_space_df) + geom_tile(aes(x=x, y=y, fill=pred)) + 
  geom_contour(aes(x=x, y=y, z=pred, col="red"), )  + theme_bw() + facet_grid(war~month) +
  scale_fill_viridis_c(name='NDVI') + coord_equal() +
  labs(x='Longitude', y='Latitude') + guides(alpha="none", colour="none") + geom_sf(data=Ukr_bnds, alpha=0) +
  theme(legend.key.size = unit(1, 'cm'), legend.position = "bottom")

space_month_year_plot




## ----echo = TRUE, fig.align='center', fig.height=5, fig.width=8, fig.asp=.6, warning=FALSE----

# Plot partial effect of year
all_gam_viz <- getViz(all_gam)

all_gam_year_plot_dat <- plot(sm(all_gam_viz, 1))$data$fit

Ukr_year_plot <- ggplot(data = all_gam_year_plot_dat) + 
  geom_line(aes(x = x, y = y)) +
  geom_ribbon(aes(x = x, ymin = y-se, ymax = y+se), alpha = 0.2) + 
  theme_bw() +
  scale_x_continuous(breaks = seq(2012, 2022,1)) +
  labs(y = "NDVI", x = "Year")

Ukr_year_plot




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
library(gstat)
library(itsadug)
library(maps)

# Bring in NDVI data
NDVI_mod_df <- readRDS('data/NDVI_mod_df.rds')

# NDVI_mod_df includes a war term for pre and post 2022 calendar years, 
# but we also need to create a pre and post-invasion term
# (24th Feb 2022) which we do below.

# Allocate factor for invasion
NDVI_mod_df$inv <- as.factor(if_else(NDVI_mod_df$date < '2022-02-24', "0", "1"))

# Bring in Ukraine bounds
Ukr_bnds <- st_read('data/UKR_adm0.shp')

# Define GAMs
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

# Run GAMs for large datasets
all_gam <- bam(all_f, data=NDVI_mod_df, discrete=TRUE, nthreads=8, rho=0.8)

# Check for temporal and spatial autocorrelation
resids <- residuals.gam(all_gam)
acf_plot_ar <- acf(resids, type = "correlation")

# Temporal autocorrelation plot, decreasing with lag but still some evident.
plot(acf_plot_ar)

# variogram for spatial autocorrelation
data_pred <- data.frame(resids = resids, long = NDVI_mod_df$x, lat = NDVI_mod_df$y)
coordinates(data_pred) <- ~long+lat
var_plot <- variogram (resids ~ 1, data = data_pred[sample(1:nrow(data_pred), 10000),])  # Select a sample for compute efficiency  
plot(var_plot)

# Run other GAMs with factors
all_gam_war <- bam(all_f_war, data=NDVI_mod_df, discrete=TRUE, nthreads=8, rho=0.6)
all_gam_inv <- bam(all_f_inv, data=NDVI_mod_df, discrete=TRUE, nthreads=8, rho=0.6)

# Output shows effect of war on cropland NDVI, listed in manuscript
summary(all_gam_inv)

# Get predictions for plotting
all_gam_war_pred <- predict(all_gam_war, se=TRUE)

all_gam_war_pred_df <- data.frame(pred = all_gam_war_pred$fit,
                                  pred_se = all_gam_war_pred$se.fit,
                                  x = NDVI_mod_df$x,
                                  y= NDVI_mod_df$y,
                                  year = NDVI_mod_df$year,
                                  month = NDVI_mod_df$month,
                                  war=NDVI_mod_df$war,
                                  date=NDVI_mod_df$date)


# Filter to current time period to allow comparison of baseline to 2022
all_gam_war_pred_space_df <- all_gam_war_pred_df %>% filter(month < 7)

# Organise data for space plot by month
all_gam_war_pred_space_df$month_b <- format(all_gam_war_pred_space_df$date, '%b')
all_gam_war_pred_space_df$month_b <- factor(all_gam_war_pred_space_df$month_b, 
                                            levels = c("Jan", "Feb", "Mar",
                                                       "Apr", "May", "Jun"))

# Figure 2 - map of Ukraine NDVI
space_month_year_plot <- ggplot(data=all_gam_war_pred_space_df) + geom_tile(aes(x=x, y=y, fill=pred)) + 
  geom_contour(aes(x=x, y=y, z=pred, col="red"), )  + theme_bw() + facet_grid(war~month_b) +
  scale_fill_viridis_c(name='NDVI') + coord_equal() +
  labs(x='Longitude', y='Latitude') + guides(alpha="none", colour="none") + geom_sf(data=Ukr_bnds, alpha=0) +
  theme(legend.key.size = unit(1, 'cm'), legend.position = "bottom")

ggsave('space_year_month_plot_wide.jpg', height=5, width=12, dpi=900, plot= space_month_year_plot)

# Plot partial effect of year
all_gam_viz <- getViz(all_gam)

all_gam_year_plot_dat <- plot(sm(all_gam_viz, 1))$data$fit

# Figure 1 - partial effect of year on NDVI
Ukr_year_plot <- ggplot(data=all_gam_year_plot_dat) + geom_line(aes(x=x, y=y)) +
  geom_ribbon(aes(x=x, ymin=y-se, ymax=y+se), alpha=0.2) + theme_bw() +
  scale_x_continuous(breaks=seq(2012, 2022,1)) +
  labs(y="NDVI", x="Year")

ggsave('Ukr_year_plot.jpg', dpi=900, height=3, width=6, plot=Ukr_year_plot)

#################### End #########################

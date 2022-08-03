library(stringr)
library(tidyverse)
library(gratia)
library(rgee)
library(mgcv)
library(rgdal)
library(sf)
library(mgcViz)
library(scales)
library(gridExtra)
library(ggsci)
library(itsadug)
library(maps)

# Bring in fire data from FIRMS
fire_mod_df <- readRDS('data/fire_mod_df_full.rds')

# Note in that dims are 37 x 82, store this so we can calc. % fire pixels from total pixels
pixels <- 37*82

# % fire analysis 

month_pc_ts <- fire_mod_df %>% 
  
  mutate(fire_inc=if_else(fire=="NaN", 0,1)) %>% 
  group_by(year, war,month) %>% 
  summarise(fire_pc_mean = mean(sum(fire_inc)/(pixels*length(unique(date)))))

month_pc_ts <- month_pc_ts %>% group_by(war, month) %>% 
  summarise(fire_pc = mean(fire_pc_mean),
            fire_pc_sd = sd(fire_pc_mean, na.rm = TRUE))

# Cumulative fire area plot
cum_plot_dat <-  fire_mod_df %>% mutate(fire_inc=if_else(fire=="NaN", 0,1)) %>% 
  group_by(year, war,month, day) %>% 
  summarise(fire_pc_mean = mean(sum(fire_inc)/(pixels*length(unique(date))))) %>%
  group_by(war, month) %>% 
  summarise(fire_pc = mean(fire_pc_mean),
            fire_pc_sd = sd(fire_pc_mean, na.rm = TRUE)) %>% 
  mutate(fire_pc_cumsum = cumsum(fire_pc))

head(cum_plot_dat)

# Figure 3 in manuscript - cumulative fire area
cumsum_fire_plot <- ggplot(data=cum_plot_dat) + geom_smooth(aes(x=month, y=fire_pc_cumsum, col=war, fill=war)) +
  scale_color_npg(name="") + scale_fill_npg(name="") +
  theme_bw() +  scale_y_continuous(labels = scales::percent) +
  scale_x_continuous(breaks=seq(1,12,1))+ labs(x="Month", y="Cumulative cropland fire area (%)") 

ggsave('Ukr_cumsum_fire_plot.jpg', width=6, height=3, dpi=900, plot =cumsum_fire_plot)

######################### Ends ##################################

options(repos = c(
  tbeptech = 'https://tbep-tech.r-universe.dev',
  CRAN = 'https://cloud.r-project.org'))

install.packages("remotes")
install.packages("")
install.packages("gdal")
# install the most recent development version of EPA spsurvey from GitHub
remotes::install_github("USEPA/spsurvey", ref = "main")

# Load packages
library(sf)
library(tidyverse)
library(mapview)
library(leaflet)
library(units)
library(stars)
library(raster)
library(here)
library(spatstat)
library(remotes)
library(tbeptools)
library(spsurvey)
library(rgdal)

#load seagrass kml layer
nssg<- st_read("North Shore Flat.kml")
nssg<- st_zm(nssg, drop = T)

trans<-st_read("TBEP_Northshore_Seagrass_Transects_NAD_2011.shp")


# reproject layers
prj4 <- '+proj=tmerc +lat_0=24.33333333333333 +lon_0=-82 +k=0.999941177 +x_0=200000.0001016002 +y_0=0 +ellps=GRS80 +to_meter=0.3048006096012192 +no_defs'
nssg <- nssg %>% 
  st_transform(crs = prj4)

shoal <- shoal %>% 
  st_transform(crs = prj4)
trans <- trans %>% 
  st_transform(crs = prj4)

mapview(nssg)+
mapview(trans)

###Load bathy file, filter out all depths >2
load(file = 'data/dem (1).RData')
dem[dem[] < -2] <- NA


##Select unstratified sampling; equal inclusion probability sampling
#"https://cran.r-project.org/web/packages/spsurvey/vignettes/sampling.html"
eqprob <- grts(nssg, n_base = 6)
sp_plot(eqprob)


#transform list of sites into a dataframe and project to prj4 for consistency
sg_starts<- as.data.frame(eqprob$sites_base)
write.csv(sg_starts, "C:\\Users\\sheil\\Desktop\\ns-sg\\sg_starts.csv")


sg_starts_geo<-st_as_sf(sg_starts,coords = c("lon_WGS84","lat_WGS84"), crs=4326)
sg_starts_geo<-sg_starts_geo %>% st_transform(crs = prj4)

#Generate a map selected sites
mapview(trans)+ mapview(sg_starts_geo)

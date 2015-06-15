
library(rgdal)
library(ggplot2)
library(maptools)
library(plyr)
library(leafletR)
library(rgeos) #for simplification
library(sp)
library(rbison)


library(devtools)
library(rgbif)
#install_github("rstudio/leaflet")
#devtools::install_github("username/packagename")

# shp <- readOGR(dsn = "C:/SATELLITE_STUFF/Landsat_TIR/R_shp", layer = "2014_HumanActivity_Postcode_Plus_30x30m")
# names(shp) ### choose "MEANMEANHu"

# shp@data$id <- rownames(shp@data)

# shp.points <- fortify(shp, region="id")

# shp.df <- join(shp.points, shp@data, by="id")

# ggplot(shp.df,aes(x=long, y=lat, fill=MEANMEANHu)) + coord_equal() + geom_polygon(colour="white", size=0.1, aes(group=group))
# ggplot(shp.df,aes(x=long, y=lat, fill=total)) + coord_equal() + geom_polygon(colour="white", size=0.1, aes(group=group))

###########################################################################

dir <- "C:/R_shp/OX_HEAT_FK_TE"
filename <- "2014_HumanActivity_Postcode_Plus_30x30m.shp"
filename <- gsub(".shp", "", filename)
dat<-readOGR(dir, filename) 

# ----- Transform to EPSG 4326 - WGS84 (required)
dat<-spTransform(dat, CRS("+init=epsg:4326"))

# ----- change name of field we will map
names(dat)[names(dat) == "name"]<-"Postcode"

names(dat)[names(dat) == "MEANMEANHu"]<-"Human_Activity_Summer_2014"

dat_data<-dat@data[,c("Postcode", "Human_Activity_Summer_2014")]


# ----- simplification yields a SpatialPolygons class
#dat<-gSimplify(dat,tol=0.01, topologyPreserve=TRUE)

# ----- to write to geojson we need a SpatialPolygonsDataFrame
dat<-SpatialPolygonsDataFrame(dat, data=dat_data)


# ----- Write data to GeoJSON
#leafdat<-paste(downloaddir, "/", filename, ".geojson", sep="") 
leafdat<-paste(dir, "/",  ".geojson", sep="") 
leafdat

####  ATT !!!!! erase existing .geojson file when re-runing code ######
writeOGR(dat, leafdat, layer="", driver="GeoJSON")  ## erase existing .geojson file when re-runing code 

# ----- Create the cuts
cuts<-round(quantile(dat$Human_Activity_Summer_2014, probs = seq(0, 1, 0.20), na.rm = FALSE), 0)
cuts[1]<- 32 # ----- for this example make first cut 32 degree celsius


# ----- Fields to include in the popup
popup<-c("Postcode", "Human_Activity_Summer_2014")

# ----- Gradulated style based on an attribute
sty<-styleGrad(prop="Human_Activity_Summer_2014", breaks=cuts, right=FALSE, style.par="col",
               style.val=rev(heat.colors(5)), leg="Human_Activity (Summer, 2014)", lwd=1)


# ----- Create the map and load into browser
map<-leaflet(data=leafdat, dest=dir, style=sty,
             title="index", base.map="osm",
             incl.data=TRUE,  popup=popup)

# ----- to look at the map you can use this code
browseURL(map)

############ GITHUB appl...under development ############

#gist("C:/SATELLITE_STUFF/Landsat_TIR/R_shp/.geojson", description = "Human Activity Oxfo
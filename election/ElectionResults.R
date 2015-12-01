#install.packages("maptools")
#library(maptools)
#gor=readShapeSpatial('~/Downloads/Census2011_Electoral_Divisions_generalised20m/Census2011_Electoral_Divisions_generalised20m.shp')
#plot(gor)

#gpclibPermit()
require("rgeos")
require("gpclib")
require("rgdal") # requires sp, will use proj.4 if installed
require("maptools")
require("ggplot2")
require("plyr")

# http://census.cso.ie/censusasp/saps/boundaries/ED_SA%20Disclaimer1.htm
setwd("~/Downloads/Census2011_Constituencies_2007/")
elect2 <- readOGR(dsn=".",layer="Census2011_Constituencies_2007")
elect2@data$id = rownames(elect2@data)
elect2.points = fortify(elect2, region="id")
elect2.df = join(elect2.points, elect2@data, by="id")

str(elect2.df)

#ggplot(elect2.df) + 
#  aes(long,lat,group=group,fill=Male2011) + 
#  geom_polygon() +
#  #geom_path(color="white") +
#  coord_equal() +
#  scale_fill_continuous("Constituency")

result <- read.csv("~/Downloads/ElectionResults.csv",header = TRUE)
str(result)
result

elect2@data$CON_2007 <- as.numeric(elect2@data$CON_2007)
result$CON_2007 <- as.numeric(rownames(result))
# swap limerick and limerick city
result[30,"CON_2007"]<-31
result[31,"CON_2007"]<-30

elect2@data <- join(elect2@data,result,by="CON_2007")
elect2_res.points = fortify(elect2, region="id")
elect2_res.df = join(elect2_res.points, elect2@data, by="id")

library(scales)
require(grid)

no_margins <- theme(
  axis.line =         element_blank(),
  axis.text.x =       element_blank(),
  axis.text.y =       element_blank(),
  axis.ticks =        element_blank(),
  axis.title.x =      element_blank(),
  axis.title.y =      element_blank(),
  axis.ticks.length = unit(0, "cm"),
  axis.ticks.margin = unit(0, "cm"),
  panel.background =  element_blank(),
  panel.border =      element_blank(),
  panel.grid.major =  element_blank(),
  panel.grid.minor =  element_blank(),
  plot.background =   element_blank(),
  plot.title =        element_blank(),
  plot.margin =       unit(c(0, 0, 0, 0), "lines")
)  

# You can use "small" for testing out colours etc
# as running on the full elect2_res takes a while
small <- elect2_res.df[seq(1, nrow(elect2_res.df), 200), ] 

p <- ggplot(elect2_res.df) + 
  aes(long,lat,group=group,fill=X..in.Favour) + 
  geom_polygon() +
  geom_path(color="gray10",size=0.2) +
  coord_equal() +
  scale_fill_gradientn("% In Favour",colours=c(muted("red"),"white",muted("green")),limits=c(25,75)) +
  no_margins

p_cb <- ggplot(elect2_res.df) + 
  aes(long,lat,group=group,fill=X..in.Favour) + 
  geom_polygon() +
  geom_path(color="gray10",size=0.2) +
  coord_equal() +
  scale_fill_gradientn("% In Favour",colours=c(muted("red"),"white",muted("blue")),limits=c(25,75)) +
  no_margins

p_small <- ggplot(small) + 
  aes(long,lat,group=group,fill=X..in.Favour) + 
  geom_polygon() +
  geom_path(color="gray10",size=0.2) +
  coord_equal() +
  scale_fill_gradientn("% In Favour",colours=c(muted("red"),"white",muted("green")),limits=c(25,75)) +
  no_margins


colnames(elect2_res.df)

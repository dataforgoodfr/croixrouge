### FIND THE 2 CLOSEST other social centers TO EACH CROIX ROUGE CENTER
require(leaflet)
require(data.table)
library(colorspace)
library(sp)
require(rgeos)
require(FNN)

source("/home/selim/Desktop/croixrouge/R/tools/exp_tools.R")
source("/home/selim/Desktop/croixrouge/R/tools/gmapapi.R")

#load center and shop data. keep only commercial centers which were successfully geocoded
banqal = read.csv("data/position_centres_2015_banque_alimentaire.csv", sep = ";")
rcoeur = read.csv("data/position_centres_2015_restos_du_coeur.csv", sep = ";")
load("~/Desktop/croixrouge/R/shiny/U2A_VIZ/data/near_shop.RData")

b = data.frame(type = rep("Banque Alimentaire", nrow(banqal)),
               lat_a = banqal$coord.lat,
               lng_a = banqal$coord.lng)
r = data.frame(type = rep("Resto du Coeur", nrow(rcoeur)),
               lat_a = rcoeur$coord.lat,
               lng_a = rcoeur$coord.lng) 

autre_social = rbind(b,r)

#find the closest other social center (vol d'oiseau)
near = knnx.index(autre_social[, c("lat_a","lng_a")], centres[, c("latitude","longitude")], k = 1)


#get distance and time to the closest other social center
t_autre = numeric()
d_autre = numeric()

type_autre = autre_social[near,c("type")]

for(i in 1:nrow(near_shop))
{
  print(paste(i,nrow(near_shop), sep = "/"))

  origin = c(near_shop[i,]$lat_c,near_shop[i,]$lng_c)
  destination = c(autre_social[near[i],]$lat_a,autre_social[near[i],]$lng_a)
  ret = getDistance(origin, destination)
  if(length(ret) == 2)
  {
    t_autre = c(t_autre, ret[2])
    d_autre = c(d_autre, ret[1]) 
  }
  else
  {
    warning(paste0("problem at iteration n#",i))
    t_autre = c(t_autre, NA)
    d_autre = c(d_autre, NA)
  }
  
}  


### test that the conversion went well
stopifnot(length(t_autre) == length(d_autre), length(t_autre) == nrow(near_shop))

#add vectors
data_u2a_viz = data.frame(near_shop)
data_u2a_viz = cbind(data_u2a_viz,
                     data.frame(type_autre = type_autre,
                                lat_a = autre_social[near, "lat_a"],
                                lng_a = autre_social[near, "lng_a"],
                                t_autre = t_autre,
                                d_autre = d_autre))

# #save the resulting table (with shops and centres)
path_save = "~/Desktop/croixrouge/R/shiny/U2A_VIZ/data/data_u2a_viz.RData"

save("data_u2a_viz","centres","shop", file = path_save)

#save("data_u2a","centres", "shop", "autre_social", "path")

## MAP TESTING
# m <- leaflet(height = "300px") %>% 
#   addTiles() %>% 
#   addCircleMarkers(lng = autre_social$lng_a,lat = autre_social$lat_a,
#                    color = "yellow",radius = 5,popup = autre_social$type)
# m <- m %>% addCircleMarkers(lng = near_shop$lng_c[1],lat = near_shop$lat_c[1],
#                             color = "red",radius = 5,popup = near_shop$centre[1])
# m
# addCircleMarkers(lng = autre_social[near[1],]$lng_a,lat = autre_social[near[1],]$lat_a,
#                  color = "yellow",radius = 5,popup = autre_social[near[1],]$type)
# Warning messages:
#   1: problem at iteration n#785 
# 2: problem at iteration n#821 
# 3: problem at iteration n#822 
# 4: problem at iteration n#823 
# 5: problem at iteration n#824 
# 6: problem at iteration n#825 
# 7: problem at iteration n#826 
# 8: problem at iteration n#827 
# 9: problem at iteration n#828 
# 10: problem at iteration n#829
k = 785
m <- leaflet(height = "300px") %>% 
  addTiles() %>% 
  addCircleMarkers(lng = autre_social[near[k],]$lng_a,lat = autre_social[near[k],]$lat_a,
                   color = "yellow",radius = 5,popup = autre_social[near[k],]$type)
m <- m %>% addCircleMarkers(lng = near_shop$lng_c[k],lat = near_shop$lat_c[k],
                            color = "red",radius = 5,popup = near_shop$centre[k])
m





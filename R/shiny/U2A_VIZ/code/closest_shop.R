### FIND THE 2 CLOSEST SHOPS TO EACH CROIX ROUGE CENTER

require(leaflet)
require(data.table)
library(colorspace)
library(sp)
require(rgeos)
require(FNN)

source("/home/selim/Desktop/croixrouge/R/tools/exp_tools.R")
source("/home/selim/Desktop/croixrouge/R/tools/gmapapi.R")

#load center and shop data. keep only commercial centers which were successfully geocoded
centres = read.csv("/home/selim/Desktop/croixrouge/R/shiny/U2A_VIZ/data/adresse_U2A.geocoded.codeinsee.csv")
shop = read.csv("/home/selim/Desktop/croixrouge/R/shiny/U2A_VIZ/data/enseignes_france.csv")
shop = shop[!is.na(shop$latitude),]

#find the 2 closest shops (vol d'oiseau) to each center
near = knnx.index(shop[, c("latitude","longitude")], centres[, c("latitude","longitude")], k = 2)


#table were the results will be stocked
table = data.frame(centre = centres$Code.U2A,
                   coord_c = paste(centres$latitude,centres$longitude, sep = ','),
                   ind_shop1 = near[,1],
                   ind_shop2 = near[,2],
                   coord_s1 = paste(shop[near[,1],]$latitude,shop[near[,1],]$longitude, sep = ','),
                   coord_s2 = paste(shop[near[,2],]$latitude,shop[near[,2],]$longitude, sep = ','))


#get distance and time to the two closest shops using the google API
t1 = character()
t2 = character()
d1 = character()
d2 = character()

for(i in 1:nrow(table))
{
  print(paste(i,nrow(table), sep = "/"))
  #shop 1
  origin = as.character(table[i,]$coord_c)
  destination = as.character(table[i,]$coord_s1)
  ret = getDistance(origin, destination)
  t1 = c(t1, ret[2])
  d1 = c(d1, ret[1])
  
  #shop 2
  origin = as.character(table[i,]$coord_c)
  destination = as.character(table[i,]$coord_s2)
  ret = getDistance(origin, destination)
  t2 = c(t2, ret[2])
  d2 = c(d2, ret[1])
}  


### test that the conversion went well
stopifnot(length(t1) == length(t2), length(d1) == length(d2), length(t1) == length(d1))

### correct errors
t2 = c(t2[1:822], NA, t2[823:length(t2)])
d2 = c(d2[1:822], NA, d2[823:length(d2)])

# complete the table with the values of t and d
table = cbind(table, d1 = d1, t1 = t1, d2=d2, t2=t2)

#modified table, and renamed to near_shop
cc = unlist(strsplit(as.character(table$coord_c),","))
cs1 = unlist(strsplit(as.character(table$coord_s1),","))
cs2 = unlist(strsplit(as.character(table$coord_s2),","))

lat_c = numeric()
lng_c = numeric()
lat_s1 = numeric()
lng_s1 = numeric()
lat_s2 = numeric()
lng_s2 = numeric()

for(i in 0:(nrow(table)-1))
{
  lat_c = c(lat_c, as.numeric(cc[2*i+1]))
  lat_s1 = c(lat_s1, as.numeric(cs1[2*i+1]))
  lat_s2 = c(lat_s2, as.numeric(cs2[2*i+1]))
  lng_c = c(lng_c, as.numeric(cc[2*i+2]))
  lng_s1 = c(lng_s1, as.numeric(cs1[2*i+2]))
  lng_s2 = c(lng_s2, as.numeric(cs2[2*i+2]))  
}

near_shop = data.frame(centre = table$centre,
                       lat_c = lat_c,
                       lng_c = lng_c,
                       ind_shop1 = table$ind_shop1,
                       ind_shop2 = table$ind_shop2,
                       lat_s1 = lat_s1,
                       lng_s1 = lng_s1,
                       lat_s2 = lat_s2,
                       lng_s2 = lng_s2,
                       d1 = table$d1,
                       t1 = table$t1,
                       d2 = table$d2,
                       t2 = table$t2)


#save the resulting table (with shops and centres)
path_save = "~/Desktop/croixrouge/R/shiny/U2A_VIZ/data/near_shop.RData"
save("near_shop","centres","shop", file = path_save)
  


## MAP TESTING
# m <- leaflet(height = "300px") %>% 
#   addTiles() %>% 
#   addCircleMarkers(lng = centres$long,lat = centres$lat,
#                    color = "red",radius = 5,popup = centres[["Libellé.U2A"]])



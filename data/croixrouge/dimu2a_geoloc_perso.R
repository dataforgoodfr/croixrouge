load("/home/selim/Desktop/croixrouge/R/RData/aida_agg.RData")
source("/home/selim/Desktop/croixrouge/R/tools/exp_tools.R")
require(data.table)
require(gdata)
names(aida_agg)

aida_agg_u2a = aida_agg[["DIM_U2A"]]
add_u2a = fread("/home/selim/Desktop/croixrouge/data/croixrouge/adresse_U2A.csv")
pos_centres = data.table(read.xls("/home/selim/Desktop/croixrouge/data/croixrouge/position_centres_2015_CRF.xlsx"))
geocod_1 = fread("/home/selim/Desktop/croixrouge/data/croixrouge/adresse_U2A.geocoded.csv")
geocod_2 = fread("/home/selim/Desktop/croixrouge/data/croixrouge/adresse_U2A.geocoded.codeinsee.csv")



### QUESTIONS

##q 0: y a-til des centres representes plusieurs fois dans DIM_U2A ? (redondance CD_U2A ou LB_U2A
## ou CD_STR)
c = colinfo(aida_agg_u2a)
print(paste0("proportion de CD_U2A uniques: ",c$PROP_UNIQUE[c$COL == "CD_U2A"]))
print(paste0("proportion de LB_U2A uniques: ",c$PROP_UNIQUE[c$COL == "LB_U2A"]))
print(paste0("proportion de CD_STR uniques: ",c$PROP_UNIQUE[c$COL == "CD_STR"]))

##duplicatas de LB_U2A:
## 1) les centres qui non pas de labels "A DEFINIR" (normal)
## 2) 1 centre irregulier: "Centre distribution Pont de Beauvoisin"
## pq ? possible qu'il y ait au meme endroit un entrepot et un centre de distribution ?
aida_agg_u2a$LB_U2A[duplicated(aida_agg_u2a$LB_U2A)]

##duplicatas de CD_STR
## que represente exactement CD_STR ?
## signification ? : 
## hyp 1: plusieurs centres differents ont le meme CD_STR --> pb
## hyp 2: CD_STR est plus global que CD_U2A: plusieurs centres differents peuvent etre localises au meme
## "endroit" capture par CD_STR
aida_agg_u2a[duplicated(aida_agg_u2a$CD_STR), c("CD_U2A","LB_U2A","CD_STR"), with = F]

## question 1: combien de centres de aida_agg_u2a ont leur equivalent (cd_str --> str_numero ) 
## dans position_centres.xls ?
f1 = levels(factor(aida_agg_u2a$CD_STR))
f2 = levels(factor(pos_centres$STR_NUMERO))
print(sprintf("nb de centres differents dans DIM_U2A: %d ", length(f1)))
print(sprintf("nb de centres de DIM_U2A qui ont leur equivalent dans pos_centre.xls : %d",sum(f1 %in% f2)))

## question 2: ces correspondances aida_agg --> position_centres.xls sont elles coherentes ? (verifier la geolocalisation approximative)
corr_existe = aida_agg_u2a$CD_STR[aida_agg_u2a$CD_STR %in% pos_centres$STR_NUMERO]

##


##correspondance aida_agg_u2a et addresse_u2a:
names(aida_agg_u2a)
names(add_u2a)
colinfo(add_u2a)
colinfo(aida_agg_u2a)
sum(aida_agg_u2a$CD_U2A %in% add_u2a[["Code U2A"]])

#centres de aida_agg_u2a qui ne sont pas dans add_u2a:
aida_agg_u2a$CD_U2A[!(aida_agg_u2a$CD_U2A %in% add_u2a[["Code U2A"]])]

cd_str_u1501 = aida_agg_u2a$CD_STR[aida_agg_u2a$CD_U2A == "U1501"]
cd_str_u1501 %in% pos_centres$STR_NUMERO
pos_centres[pos_centres$STR_NUMERO == cd_str_u1501]

cd_str_witbe = aida_agg_u2a$CD_STR[aida_agg_u2a$CD_U2A == "WITBE"]
cd_str_witbe %in%pos_centres$STR_NUMERO
pos_centres[pos_centres$STR_NUMERO == cd_str_witbe]
## les differents types de centres u2a:
unique(add_u2a[["Action menée"]])


## libelles des centres pour aida_agg_u2a et add_u2a avec correspondance de code
ss = add_u2a[,c("Code U2A","Libellé U2A"), with = F]
ss = cbind(ss, sapply(add_u2a[["Code U2A"]], 
           FUN = function(x){ if(x %in% aida_agg_u2a$CD_U2A) aida_agg_u2a$LB_U2A[aida_agg_u2a$CD_U2A == x] else "NA"}))


## CD_STR de aida pas repertories dans pos centres
## --> aller chercher lat long avec les adresses grace a google api ==> PAS BESOIN.
length(unique(aida_agg_u2a$CD_STR))
length(unique(aida_agg_u2a$CD_STR) %in% unique(pos_centres[["STR_NUMERO"]]))


# centres qui sont dans add_u2a et pas dans aida_agg_u2a
add_u2a[!(add_u2a[["Code U2A"]] %in% aida_agg_u2a[["CD_U2A"]])]
#centre qui sont dans aida_agg_u2a et pas dans add_u2a
aida_agg_u2a[!(aida_agg_u2a[["CD_U2A"]] %in% add_u2a[["Code U2A"]])]


# #### UPDATE DE LA TABLE aida_agg[["DIM_U2A"]]
# ###---------------------------------------------
## suppression du code "WITBE" qui ne correspond a rien.
aaa = aida_agg_u2a[aida_agg_u2a$CD_U2A != "WITBE",
                              c("CD_U2A","CD_STR", "CD_DEPT", "LB_DEPT", "CD_REGION", "LB_REGION"), with = F]

## get the labels of 
aaa = cbind(aaa, LB_U2A = sapply(aaa$CD_U2A, 
                           FUN = function(x) 
                             {if(x %in% add_u2a[["Code U2A"]])
                               add_u2a[["Libellé U2A"]][add_u2a[["Code U2A"]] == x]
                              else
                                aida_agg_u2a[["LB_U2A"]][aida_agg_u2a[["CD_U2A"]] == x] 
                              } ))

length(unique(aaa$CD_U2A) %in% unique(add_u2a[["Code U2A"]]))
length(unique(aaa$CD_U2A))
aaa = cbind(aaa, data.table(ACTION = sapply(aaa$CD_U2A, FUN = function(x){ add_u2a[["Action menée"]][add_u2a[["Code U2A"]] == x]})),
            data.table(ADRESSE = sapply(aaa$CD_U2A, FUN = function(x){ add_u2a[["Adresse"]][add_u2a[["Code U2A"]] == x]})))            
            

aaa = cbind(aaa, 
            data.table(LAT = sapply(aaa$CD_STR, FUN = function(x){ pos_centres[["latitude"]][pos_centres[["STR_NUMERO"]] == x]})),
            data.table(LONG = sapply(aaa$CD_STR, FUN = function(x){ pos_centres[["longitude"]][pos_centres[["STR_NUMERO"]] == x]})))


# ###---------------------------------------------
  
geoloc2 = fread("/home/selim/Desktop/croixrouge/data/croixrouge/adresse_U2A.geocoded.csv")
### remove unecessary columns
geoloc2[, c("result_type", "result_score","result_address","result_id"):=NULL]
### TOUTES LES POSSIBILITES D'ABSENCE DE GEOLOCALISATION
## no lat/long and no address
#1) get the lat/long
no_address_i = sapply(geoloc2$Adresse, FUN = function(x){nchar(x) == 4})
codes = geoloc2[no_address_i][["Code U2A"]]
add = data.table(LAT = numeric(), LONG = numeric())
for(i in 1:length(codes)) 
    add = rbind(add, aaa[, c("LAT","LONG"), with = F][aaa$CD_U2A == codes[i]])
geoloc2[no_address_i]$latitude = add$LAT
geoloc2[no_address_i]$longitude = add$LONG
geoloc2[no_address_i][, c("longitude","latitude"), with = F]
#2) get the address: inverse geocoding
for(i in 1:nrow(geoloc2[no_address_i]))
{
  v = c(lon = unlist(geoloc2[no_address_i]$longitude[i])  , lat = unlist(geoloc2[no_address_i]$latitude[i])) 
  geoloc2[no_address_i]$Adresse[i] = revgeocode(v)
}  
  
## no lat/long but address
#do the geocoding
geoloc2[no_ll_i]$Adresse[15] <- "Boulevard Bouyala d'Arnaud 13012 Marseille"
geoloc2[no_ll_i]$Adresse[24] <- "Route de Dinan, 22100 Quévert"
geoloc2[no_ll_i]$Adresse[25] <- "Route de Dinan, 22100 Quévert"
geoloc2[no_ll_i]$Adresse[31] <- "455, ave Lesdiguières 38290 LA Verpilliere"
geoloc2[no_ll_i]$Adresse[38] <- "Route Albas 46140 Luzech"
geoloc2[no_ll_i]$Adresse[45] <- "rue Georges Rémy  54210 St Nicolas de Port"
geoloc2[no_ll_i]$Adresse[78] <- "2 Rue Georges Pompidou Saint-Benoît 97470 Réunion"
no_ll_i = is.na(geoloc2$latitude) & sapply(geoloc2$Adresse, FUN = function(x){nchar(x) != 4})
recpt = geocode(geoloc2[no_ll_i]$Adresse)
wrong_add_i = (is.na(recpt$lat) & is.na(recpt$lon))
colnames(recpt) <- c("longitude","latitude")
geoloc2[no_ll_i][, c("longitude","latitude")] = recpt

geoloc2[is.na(geoloc2$latitude)]

setnames(geoloc2, colnames(geoloc2), c("CD_U2A","LB_U2A","ACTION","ADRESSE","LAT","LON"))
additional_info = aida_agg_u2a[, c("CD_U2A","CD_STR","CD_DEPT","LB_DEPT","CD_REGION","LB_REGION"), with = F]
geoloc2 = merge(geoloc2, additional_info, by = "CD_U2A", all = T)
geoloc2 = geoloc2[!(geoloc2$CD_U2A == "WITBE")]

# unique(geoloc2$CD_U2A)[!(unique(geoloc2$CD_U2A) %in% unique(aida_agg_u2a$CD_U2A))]
# unique(unique(aida_agg_u2a$CD_U2A))[!(unique(aida_agg_u2a$CD_U2A) %in% unique(geoloc2$CD_U2A))]


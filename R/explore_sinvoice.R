data = fread('Downloads/stoVsDist.csv')

data$id_mois = as.Date(paste0(as.character(data$id_mois),"01"),format = '%Y%m%d')
data[["month"]] = format(data$id_mois,format='%m')

t = data[, list(mean(consoRate,trim = 0.05)),by='month']
plot(t$month, t$V1, type = 'l')

plot(head(data$dist_poids))

index = data$month == "04"
hist(data$stock_poids[index])

head(data)

data = fread("croixrouge/data/croixrouge/AIDA brut/sinvoice-utf8.txt")
data$ACCDAT_0 = as.Date(data$ACCDAT_0, format = '%d/%m/%y')

data$AMTATI_0 = as.numeric(gsub(',','.',data$AMTATI_0))
data$YREVREF_0 = as.numeric(gsub(',','.', data$YREVREF_0))
data$YQUOTFAM_0 = as.numeric(gsub(',','.', data$YQUOTFAM_0))
data$YMTVALMER_0 = as.numeric(gsub(',','.', data$YMTVALMER_0))


require(googleVis)
g = gvisCalendar(data = t[ t$ACCDAT_0 >= "2011-01-01" & t$ACCDAT_0 < '2015-01-01'],datevar = 'ACCDAT_0',numvar = 'N',options = list(width = 1024, height = 1000))
plot(g)

c('YNBR_0', 'AMTATI_0','YTYPOFAM_0', 'YCSP_0', 'YREVREF_0', 'YQUOTFAM_0', 'YFREQPASS_0')

address = fread("croixrouge//data//croixrouge//adresse_U2A.geocoded.csv")


setnames(address, 'Code U2A', 'FCY_0')
setnames(address, 'Libellé U2A', 'CenterName')
setnames(address, 'Action menée', 'CenterAction')
data = merge(data, address[,c('FCY_0', 'CenterAction'), with=F], by='FCY_0', all.x=T)

require(leaflet)
t = data[!is.na(data$latitude) & !is.na(data$longitude) & data$YMTVALMER_0 < quantile(data$YMTVALMER_0, 0.99995),list(Count = sum(!is.na(YMTVALMER_0)), Total = sum(YMTVALMER_0, na.rm=T)),by='latitude,longitude,CenterName,CenterAction,ACCDAT_0']

pal = colorFactor(pinkgreen(9), unique(address$CenterAction))

data = t

pinkgreen = colorRampPalette(brewer.pal(n = 9,name = "PiYG"))

m = leaflet(t) %>%
  addTiles %>%
  addCircleMarkers(lng = t$longitude,lat = t$latitude,radius = 30 * (t$Total-min(t$Total))/(max(t$Total) - min(t$Total)),popup = paste(paste0("<br>Center Name : ", t$CenterName), paste0("<br>Total transaction = ", round(t$Total,2)),sep = '</br>'), col = "red", opacity = 0.8)
m

address

CreateURLCenter <- function(name, type = "addressdetails")
{
  return(paste0("http://nominatim.openstreetmap.org/search?format=json&countrycodes=FR&", type,"=", name))
}

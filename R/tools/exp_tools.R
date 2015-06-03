#functions
# ginfo <- function(dt)
# colinfo <- function(dt)
# search_nas <- function(dts)
# search_dup <- function(dts, dt2 = NULL, remove = F)
# solve_encoding <- function(dt)
# check_col <- function(dts, col_names)
# info_date <- function(dts, name_month)
# r_to_sql: create an sql database from a list of R data tables
# sql_to_r: create a list of R data tables from an sql database


### exp_tools.R
### tool functions for exploring databases.

# for tables where there is the date information (month), check :
#period covered
#missing months
#number of quotes per date
info_date <- function(dt, name_month = "ID_MOIS")
{
  check_col(aida_agg, name_month)
  start_date = as.character(min(dt[[name_month]]))
  starty = as.numeric(substr(start_date,1,4))
  startm = substr(start_date,5,6)
  end_date = as.character(max(dt[[name_month]]))
  endy = substr(end_date,1,4)
  endm = substr(end_date,5,6)
  dates = numeric()
  months = c("01","02","03","04","05","06","07","08","09","10","11","12")
  years = as.character(starty:endy)
  for(yr in years)
    dates = c(dates, as.numeric(paste0(yr,months)))
  dates <- as.character(dates[dates >= start_date & dates <= end_date])
  
  ret = data.table(ID_MOIS = dates,
                   NB_QUOTES = sapply(dates, FUN = function(x){ sum(dt[[name_month]] == x)}))
  ret
}

glob_info_date <- function(dts = aida_agg)
{
  
  tbles = check_col("ID_MOIS")
  start = character()
  end = character()
  miss = numeric()
  miss_months = character()
  for(nm in tbles)
  {
    inf_date = info_date(dts[[nm]])
    start = c(start, inf_date[1, "ID_MOIS", with = F])
    end = c(end, inf_date[nrow(inf_date), "ID_MOIS", with = F]) 
    miss = c(miss, sum(inf_date$NB_QUOTES == 0))
    miss_months = c(miss_months, paste(inf_date$ID_MOIS[inf_date$NB_QUOTES == 0], collapse = ', '))
  }
  
  ret = data.table(TABLE = tbles,
                   START = start,
                   END = end,
                   NB_MISS_MONTH = miss,
                   MISSING_MONTH = miss_months)
}



#global information on a data table
ginfo <- function(dt)
{ 
  ret = data.table(NB_QUOTES = nrow(dt), 
                   NB_DUP = sum(duplicated(dt)), 
                   PROP_DUP = sprintf("%.1f %%", 100*sum(duplicated(dt))/nrow(dt)) ,
                   NB_INCOMPLETE = sum(!complete.cases(dt)) ,
                   PROP_INCOMPLETE = sprintf("%.1f %%", 100*sum(!complete.cases(dt))/nrow(dt)))
  ret
}

#information about each column of the data table
colinfo <- function(dt)
{   
  NB_NA = sapply(dt, FUN = function(x) { sum(is.na(x))})
  PROP_NA = sapply(dt, FUN = function(x) { sprintf("%.1f %%", 100* sum(is.na(x))/nrow(dt))})
  NB_UNIQUE = sapply(dt, FUN = function(x) { length(unique(na.omit(x))) })
  PROP_UNIQUE = sapply(dt, FUN = function(x) { sprintf("%.1f %%",100 * length(unique(na.omit(x)))/ nrow(dt))})
  
  COL = colnames(dt)
  ret = data.table(COL, NB_NA, PROP_NA, NB_UNIQUE,PROP_UNIQUE, keep.rownames = T)
  ret
}
  
#look for all the data tables that contain NAs
search_nas <- function(dts)
{
  tables = character()
  for(nm in names(dts))
    if(sum(is.na(dts[[nm]])) != 0)
      tables <- c(tables, nm)
  tables
}


#look for all the data tables that contain duplicates
search_dup <- function(dts, dt2 = NULL, remove = F)
{
  if(is.null(dt2))
  {
    
    tables = character()
    for(nm in names(dts))
    {
      if(sum(duplicated(dts[[nm]])) != 0)
        tables <- c(tables, nm)
    }

    tables 
  }
  else
  {
    tp = rbind(dts, dt2)
    print(ginfo(tp))
    if(remove)
      return(tp[!duplicated(tp)])
    else
      return(tp[duplicated(tp)])
  } 
}

#solve encoding problems in a column
solve_encoding <- function(dt)
{
  for(cl in colnames(dt))
    if(class(dt[[cl]]) == "character")
    {
      #e
      dt[[cl]] <- gsub("(\xe8)|(\xe9)|(\xea)","e",dt[[cl]])
      # o
      dt[[cl]] <- gsub("(\U3e34663c)", "o", dt[[cl]])
      dt[[cl]] <- gsub("(\xf4)", "o", dt[[cl]])
      # a
      dt[[cl]] <- gsub("\xe2","a", dt[[cl]])
      # i
      dt[[cl]] <- gsub("\xee", "i", dt[[cl]])
      # c
      dt[[cl]] <- gsub("\xe7", "c", dt[[cl]]) 
    }
  dt
}

#check_col looks in which data tables the cols are present
check_col <- function(col_names, dts = aida_agg)
{
  tables = character()
  for(nm in names(dts))
  {
    if(sum(col_names %in% names(dts[[nm]])) ==  length(col_names))
      tables <- c(tables, nm)
  } 
  tables
}
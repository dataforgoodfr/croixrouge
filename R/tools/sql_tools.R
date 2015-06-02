### sql_tools.R
### tool function for writing to an sql file from R data tables and vis vers ca.

#to use this function, you need to install MySQL
sql_to_r <- function(dbname, user, password, host = 'localhost', rdata_path = NULL, sql_file = NULL)
{
  require(RMySQL)
  
  #connect to the database
  mydb = dbConnect(MySQL(), user = user, password = password, host = host)
  if(!is.null(sql_file))
  {
    dbSendQuery(mydb, paste0('CREATE DATABASE IF NOT EXISTS ', dbname))
    system(paste0('mysql -u ', user,' -p',password,' ', dbname ,' < ',sql_file))
  }
  
  dbSendQuery(mydb, paste0("USE ", dbname))
  tables_name = dbListTables(mydb)
  
  #fill the data table list
  dt_list = list()
  for(nm in tables_name)
  {
    if(substr(nm,1,1) == "#")
      next
    dt_list[[nm]]  = data.table(dbReadTable(mydb, nm))
  }
  
  #save the list of data tables to RData format
  if(!is.null(rdata_path))
    save(list = "dt_list", file = rdata_path) 
  
  #disconnect from the database
  dbDisconnect(mydb)
  
  #return the R datatable list
  dt_list
}


r_to_sql <- function(dt_list, dbname, user, password, host = 'localhost', sqlfile_path = NULL)
{
  require(RMySQL)
  
  #connect to the database
  mydb = dbConnect(MySQL(), user = user, password = password, host = host)
  
  dbSendQuery(mydb, paste0('DROP DATABASE ', dbname))
  dbSendQuery(mydb, paste0('CREATE DATABASE ', dbname))
  dbSendQuery(mydb, paste0("USE ", dbname))
  
  tables_name = names(dt_list)
  
  for(nm in tables_name)
    dbWriteTable(mydb, name = nm, value = dt_list[[nm]], overwrite = TRUE)
  
  #write a new sql file
  if(!is.null(sqlfile_path))
    system(paste0('mysqldump -u ',user,' -p',password, ' ', dbname ,' > ',sqlfile_path))
  
  #disconnect from the database
  dbDisconnect(mydb)
}
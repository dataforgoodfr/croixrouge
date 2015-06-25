require(XML)
require(RCurl)
require(data.table)
require(RJSONIO)

urlDepartement = 'http://supermarches.grandes-enseignes.com'
doc = htmlParse(getURL(urlDepartement))
departement = getNodeSet(doc, "//table")
departement = getNodeSet(departement[[3]], "//a")

deps = NULL
for(i in 5:(length(departement)-1))
{
  deps = c(deps,xmlAttrs(node = departement[[i]]))
}

result = list()
error = NULL
userKey = read.table(file = "croixrouge//R/userKey_import.io")$V1
for(dep in deps)
{
  myurl = paste0(urlDepartement, dep)
  print(myurl)
  doc = htmlParse(getURL(myurl))
  communes = getNodeSet(doc, "//table")
  communes = getNodeSet(communes[[5]], "//a")
  for(i in 6:(length(communes)-1))
  {
    link = xmlAttrs(node = communes[[i]])
    apiUrl = paste0("https://api.import.io/store/data/3e6739a6-c54e-4483-a759-b7b755e5c960/_query?input/webpage/url=http://supermarches.grandes-enseignes.com/", link,"&_user=", userKey)
    print(link)
    apiUrl = URLencode(apiUrl)
    urlContent = getURL(apiUrl)
    if( isValidJSON(urlContent, asText=T))
    {
      output = fromJSON(urlContent)
      if(class(output) == 'list')
      {
        temp = rbindlist(lapply(output$results, function(x) as.list(x)),use.names = T,fill = T)
        result = rbindlist(list(result, temp),use.names = T,fill = T)
      }
      else
      {
        print("pause")
        Sys.sleep(time = 20)
        urlContent = getURL(apiUrl)
        if( isValidJSON(urlContent, asText=T))
        {
          output = fromJSON(urlContent)
          if(class(output) == 'list')
          {
            temp = rbindlist(lapply(output$results, function(x) as.list(x)),use.names = T,fill = T)
            result = rbindlist(list(result, temp),use.names = T,fill = T)
          }
          else
            error = c(error, link)
        }
        else
          error = c(error, link)
      }
    }
    else
    {
      print("pause")
      Sys.sleep(time = 20)
      urlContent = getURL(apiUrl)
      if( isValidJSON(urlContent, asText=T))
      {
        output = fromJSON(urlContent)
        if(class(output) == 'list')
        {
          temp = rbindlist(lapply(output$results, function(x) as.list(x)),use.names = T,fill = T)
          result = rbindlist(list(result, temp),use.names = T,fill = T)
        }
        else
          error = c(error, link)
      }
      else
        error = c(error, link)
    }
  }
}

save(result, file = "enseignes.RData")
save(error, file = "error.RData")
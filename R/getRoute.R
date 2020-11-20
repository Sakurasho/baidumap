


#=============================================================================
getRoute = function(...){
  rawData = getRouteXML(...)
  return(xml2df(rawData))
}

getRouteXML = function(origin, destination, mode='driving', 
                       region = '上海', origin_region = NA, 
                       destination_region = NA, 
                       tactics = 0, 
                       coord_type = 'bd09ll',
                       ret_coordtype = 'bd09ll',
                       output = 'xml',
                       map_ak=''){
  
  if (map_ak == '' && is.null(getOption('baidumap.key'))){
    stop("Notification")
  }else{
    map_ak = ifelse(map_ak == '', getOption('baidumap.key'), map_ak)
  }
  
  
  if (is.na(region)){
    if (is.na(origin_region) & is.na(destination_region)) {
      stop('Argument "region" is not setted!')
    }
  }
  
  get_city = function(x) ifelse(is.na(x), region, x)
  
  origin_region = get_city(origin_region)
  destination_region = get_city(destination_region)
  ## get xml data
  serverAddress = 'http://api.map.baidu.com/directionlite/v1/driving?'
  rawData = getForm(serverAddress, 
                    origin = origin, destination = destination, 
                    # origin_region = origin_region, 
                    # destination_region = destination_region,
                    #tactics = tactics, coord_type = coord_type, ret_coordtype = ret_coordtype,
                    ak = map_ak, output = output)
  return(rawData)
}

## Json文件解析
Json2df = function(rawData){
  temp <- rjson::fromJSON(rawData)
  
}

library("rjson")

# library(jsonlite)
temp <- rjson::fromJSON(rawData)
# temp1 <- jsonlite::fromJSON(rawData, simplifyMatrix = TRUE)

summary(temp)
temp$status # 状态码，0：成功，1：服务内部错误，2：参数无效，7：无返回结果
temp$message # 状态码对应的信息
temp$result$origin$lng
temp$result$origin$lat



Step_Num <- length(temp$result$route[[1]]$steps) # 计算step的总数
df.all <- data.frame()
for (N in 1:Step_Num){
  pathLine <- temp$result$route[[1]]$steps[[N]]$path
  df <- data.frame(matrix(unlist(strsplit(unlist(strsplit(pathLine, ";")), ",")), ncol=2, byrow = TRUE))
  colnames(df)<- c("Lon", "Lat")
  df.all <- rbind(df.all, df)
  df.all$Lon <- as.numeric(df.all$Lon)
  df.all$Lat <- as.numeric(df.all$Lat)
}



# xml2df = function(rawData){
#   ## extract longitude and latitude
#   tree = htmlTreeParse(rawData, useInternal = TRUE)
#   path = xpathSApply(tree, "//path",  xmlValue)
#   split_path = function(x){
#     xVec = strsplit(x, ';')[[1]]
#     xMat = sapply(xVec, function(x) as.numeric(strsplit(x, ',')[[1]]))
#     xDf = data.frame(t(xMat), row.names = NULL)
#     colnames(xDf) = c('lon', 'lat')
#     return(xDf)
#   }
#   
#   coor_list = lapply(path, split_path)
#   ## return a dataframe
#   coors = do.call(rbind, coor_list)
#   return(coors)
# }


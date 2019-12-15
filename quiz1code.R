## Quiz 1 ## 
############

# Download housing data in Idaho 2006 

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv"
download.file(fileUrl, destfile = "IDHousing2006.csv")

dateDownloaded <- date()
dateDownloaded

# Read local flat files 
IDHousing2006 <- read.csv("IDHousing2006.csv")

## Method 1 
library(plyr)
library(dplyr)

IDHousing2006_A <- tbl_df(IDHousing2006)
IDHousing2006_A
str(IDHousing2006_A)
filter(IDHousing2006_A, VAL == 24)


## Method 2 
library(data.table)
IDHousing2006_B <- data.table(IDHousing2006)
is.data.table(IDHousing2006_B)
IDHousing2006_B[, propertyFlag:= VAL== 24]
str(IDHousing2006_B)
IDHousing2006_B[, .N, by = propertyFlag]

# Question 3 

## download data 
## Downloaded file is not valid for unknown reason. 
## Mannually download the excel data and save it to the directory as "GasProgram_M".

fileUrl2 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FDATA.gov_NGAP.xlsx"
download.file(fileUrl2, destfile = "GasProgram.xlsx")
dateDownloaded_gas <- date() 
## all the coding works. The excel file is invalid. 

# Approach 1 
## xlsx package does not work for rjava failure, fix this later
install.packages("xlsx") ## package was successfully loaded to R after installing java
library(xlsx)
list.files()
dat_mo <- read.xlsx("GasProgram_M.xlsx", sheetIndex = 1, colIndex = 7:15, rowIndex = 18:23)


# Approach 2 
## read_excel from readxl package for the mannually downloaded excel data 
install.packages("readxl")
install.packages("cellranger")
library(readxl)
library(cellranger)
str(read_excel)
?read_excel
dat1 <- read_excel("GasProgram_M.xlsx", sheet = 1, range = cell_limits(c(18, 7), c(23, 15)))
# using cell_limits to specify rows and columns simutaneously. 
str(dat1)
sum(dat1$Zip * dat1$Ext, na.rm = TRUE)


# Question 4 XML data 

## Method 1 
    ### Read XML data on Baltimore restaurants 
install.packages("XML")
library(XML)
fileUrl4 <- "http://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
# get rid of s in https
doc <- xmlTreeParse(fileUrl4, useInternal = TRUE)
rootNode <- xmlRoot(doc)
xmlName(rootNode)
names(rootNode)

    ### Extract zipcode from the data 
zip <- xpathSApply(rootNode, "//zipcode", xmlValue)
sum(zip == 21231)
    
## Method 2

### Using RCurl to deal with https. 
install.packages("RCurl")
library(RCurl)
fileUrl4_2 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Frestaurants.xml"
xmldata <- getURL(fileUrl4_2) # This step allows the use of https
doc_2 <- xmlParse(xmldata)
rootNode_2 <- xmlRoot(doc_2)
zip_2 <- xpathSApply(rootNode_2, "//zipcode", xmlValue)
sum(zip_2 == 21231)

## Method 3 convert into data frame 

zip_3 <- zip_2 
zip_df <- data.table(zip_3, keep.rownames = FALSE)
zip_df[, .N, zip_3 == 21231]




# Question 5 compare the systime for the following command 

    ## download and read data 

fileUrl5 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06pid.csv"
download.file(fileUrl5, destfile = "q5data.csv")

    ## Reading as a data frame 
DT <- read.csv("q5data.csv")
str(DT$pwgtp15)
str(DT$SEX)
is.data.table(DT)

    ## Reading data using fread as a data table 
DT1 <- fread("q5data.csv", sep = ",")
is.data.table(DT1)
    ### The following commmand lines can hardly tell the difference 
time1 <- system.time(tapply(DT1$pwgtp15, DT1$SEX, mean))
time1
time2 <- system.time(DT1[, mean(pwgtp15), by = SEX]) 
time2 
time3 <- system.time(mean(DT1$pwgtp15, by = DT1$SEX))
time3 
    
    ### So I turn to microbenchmark 
# microbenchmark package allows to compare the relative performance for 
# small pieces of source code

install.packages("microbenchmark")
library(microbenchmark)
## the fifth and sixth expression were left out because of extra cal. 
result <- microbenchmark(
    v1 = tapply(DT1$pwgtp15, DT1$SEX, mean), 
    v2 = DT1[, mean(pwgtp15), by = SEX], 
    v3 = mean(DT1$pwgtp15, by = DT1$SEX), 
    V4 = sapply(split(DT1$pwgtp15, DT1$SEX), mean)
) 
result

## Plot the performance
ggplot2::autoplot(result)
boxplot(result)











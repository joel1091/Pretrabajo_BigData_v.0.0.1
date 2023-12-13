#Paquetes preliminares

install.packages("pxR")
library(pxR)
install.packages("tidyverse")
library(tidyverse)
library(data.table)
library(rlist)
library(fs)
library(curl)
library(rio)
install.packages("readxl")
library(readxl)
install.packages("downloader")
library(downloader)
library(writexl)

#Creamos una carpeta para guardar los datos

dir_create("./docs/datos")

#Descargamos los datos en formato PX desde el Ine
#Índice de Precios de Vivienda por CCAA: general, vivienda nueva y de segunda mano
# Como la URL es:https://www.ine.es/jaxiT3/files/t/es/px/25171.px?nocab=1

url <- "https://www.ine.es/jaxiT3/files/t/es/px/25171.px?nocab=1"
aa <- read.px(url)

#Lo convertimos a CSV para simplificar y creamos un dataframe

write.csv(aa, file = "data.csv", sep = ",")
IPV <- read.csv("data.csv")


rm(list = ls()[!ls() %in% c("IPV")])

#Compra-venta de vivienda

ruta_xls <- "https://apps.fomento.gob.es/BoletinOnline2/sedal/34010110.XLS"

download.file(ruta_xls, "datos.xls", mode = "wb")

lista_datos <- lapply(excel_sheets("datos.xls"), function(sheet) {
  readxl::read_excel("datos.xls", sheet = sheet)
})

compraventa_2004 <- read.csv("2004,2005,2006,2007,2008.csv")
compraventa_2009 <- read.csv("2009,2010,2011,2012,2013.csv")
compraventa_2014 <- read.csv("2014,2015,2016,2017,2018.csv")
compraventa_2019 <- read.csv("2019,2020,2021,2022,2023.csv")

?dplyr

cv <- bind_cols(compraventa_2009,compraventa_2014)
cv <- bind_cols(cv,compraventa_2019)

compraventa_2004 <- compraventa_2004[1:nrow(cv), ]

cv <- bind_cols(cv,compraventa_2004)

unlink(archivos_a_borrar)

cv <- cv %>%
  filter(row_number() %in% 6:72)
cv <- cv %>%
  filter(!row_number() %in% 2)

rm(list = ls()[!ls() %in% c("IPV", "cv")])

#Renta por edad y sexo

url3 <- "https://www.ine.es/jaxiT3/files/t/es/px/9942.px?nocab=1"
aa <- read.px(url3)

#Lo convertimos a CSV para simplificar y creamos un dataframe

write.csv(aa, file = "data.csv", sep = ",")
renta_edad <- read.csv("data.csv")

rm(list = ls()[!ls() %in% c("IPV", "cv", "renta_edad")])


#Renta por nacionalidad

url4 <- "https://www.ine.es/jaxiT3/files/t/es/px/9945.px?nocab=1"
aa <- read.px(url4)

#Lo convertimos a CSV para simplificar y creamos un dataframe

write.csv(aa, file = "data.csv", sep = ",")
renta_nacionalidad <- read.csv("data.csv")

rm(list = ls()[!ls() %in% c("IPV", "cv", "renta_edad","renta_nacionalidad" )])

#Hogares por regimen de tenencia edad

url4 <- "https://www.ine.es/jaxiT3/files/t/es/px/9994.px?nocab=1"
aa <- read.px(url4)

#Lo convertimos a CSV para simplificar y creamos un dataframe

write.csv(aa, file = "data.csv", sep = ",")
vivienda_edad <- read.csv("data.csv")

rm(list = ls()[!ls() %in% c("IPV", "cv", "renta_edad","renta_nacionalidad", "vivienda_edad" )])

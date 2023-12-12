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

#Creamos una carpeta para guardar los datos

dir_create("./docs/datos")

#Descargamos los datos en formato PX desde el Ine
#Índice de Precios de Vivienda por CCAA: general, vivienda nueva y de segunda mano
# Como la URL es:https://www.ine.es/jaxiT3/files/t/es/px/25171.px?nocab=1

#url <- "https://www.ine.es/jaxiT3/files/t/es/px/25171.px?nocab=1"
#aa <- read.px(url)

#Lo convertimos a CSV para simplificar y creamos un dataframe

#write.csv(aa, file = "data.csv", sep = ",")
df <- read.csv("data.csv")

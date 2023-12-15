#Paquetes preliminares

library(pxR)
library(tidyverse)
library(data.table)
library(rlist)
library(fs)
library(curl)
library(rio)
library(readxl)
library(downloader)
library(writexl)
library(zoo)

#rm(list = ls())

#Creamos una carpeta para guardar los datos pulidos

dir_create("./docs/datos_pulidos")

#Cargo los datos del Indice de precios de la Vivienda para arreglarlos

cv <- import(file = "./docs/datos/cv.csv")

#Elimino las columnas duplicadas indicando el nombre de la provincia 
#para dejar solo una columna de provincias

columnas_duplicadas <- duplicated(t(cv))
print(columnas_duplicadas)
cv <- cv[, !columnas_duplicadas]

#Elimino otra columnaa duplicadaa que el argumento no encuenrtra y 2 columnas de NA

cv <- cv[, -(61:63)]

#Doy nombre a la posición [1,2] de provincias para después poder trabajar mejor
#Ya que convertiremos la primera fila en colnames

cv[1,2] <- "Provincia"
colnames(cv)

#Seleccionamos la primera fila del df y lo convertimos en un vector. Después, 
#Hacemos que los NA se sustituyan por el texto de su izquierda (Remplazamos NA`s
#por el año al que corresponde esa columnas)

df <- cv %>%
  slice(1) %>%
  unlist()

df <- na.locf(df)

#Ahora convertimos el vector en la fila 1 que después convrtiremos en colnames
#para trabajar mejor.

cv[1,] <- df 

#Juntamos la fila 1 y 2 a partir de la tercer columna separando el texto con "_" 
#y le rellenamos las dos columnas restantes con los nombres que nos vengan mejor 
#para trabajar
aa <- cv[1,]
aa <- c("","Provincia",paste(cv[1,3:80],cv[2,3:80], sep = "_"))

#Convertimos el vector aa en colnames

colnames(cv) = aa


#Quitamos la primera y la segunda fila, es información que ya indica colnames

cv <- cv[-(1:2), -(1)]
colnames(cv)

#Hacemos que todas las columnas que indican año_trimestre pivoten y dejen los
#valores que contenían las transacciones por un lado y el año_trimestre por otro

Transacciones_por_provincia <- cv %>% pivot_longer(cols = starts_with("Año"), 
                           names_to = "Año_Trimestre", 
                           names_prefix = "Año", 
                           values_to = "Transacciones",
                           values_drop_na = TRUE)

#Guardamos en la carpeta(en formato .csv) de datos pulidos y seguimos

write.csv(Transacciones_por_provincia, file = "./docs/datos_pulidos/Transacciones_por_povincia.csv")

#----------------Índice de precios de la vivienda-------------------------------


ipv <- import(file = "./docs/datos/ipv.csv")

#Estos datos están bien, quitamos las dos columnas que no aportan y los guardamos
ipv <- ipv[,-(1:2)]

write.csv(ipv, file = "./docs/datos_pulidos/indice_precio_vivienda.csv")

#rm(list = ls())
#----------------Renta por edad-------------------------------------------------

re <- import(file  = "./docs/datos/renta_edad.csv")

#Renombramos las columnas, seleccionamos lo que nos interesa y borramos el restante
#Exportamos
re <- re %>%
  rename(renta = "value") %>%
  select(!c("V1", "X"))

write.csv(re, file = "./docs/datos_pulidos/renta_por_edad.csv")

#rm(list = ls())
#----------------Régimen tenencia de vivienda por edad--------------------------

vd <- import(file  = "./docs/datos/vivienda_datos.csv")

#Renombramos las columnas, seleccionamos lo que nos interesa y borramos el restante
#Exportamos
vd<- vd %>%
  rename(Porcentaje = "value") %>%
  select(!c("V1", "X"))

write.csv(vd, file = "./docs/datos_pulidos/tenencia_de_vivienda.csv")


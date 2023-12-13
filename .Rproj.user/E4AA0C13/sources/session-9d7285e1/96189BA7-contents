#Paquetes preliminares----

install.packages("pxR")
install.packages()
library(pxR)
install.packages("tidyverse")
library(tidyverse)
library(data.table)
library(rlist)
library(fs)
library(curl)
library(rio)


#IMPORTAR DATOS CE / EUROSTAT----
options(scipen = 999) #- para quitar la notación científica

library(eurostat) #install.packages("eurostat")
library(DT) #install.packages("DT")
library(tidyverse)

info <- search_eurostat("GDP", type = "all")
my_table <-"sdg_08_10"

#Comprobamos que es el PIB pc
label_eurostat_tables(my_table)

df_original <- get_eurostat(my_table, time_format = 'raw', keepFlags = TRUE)
df_names <- names(df_original)
df_original <- label_eurostat(df_original, code = df_names, fix_duplicated = TRUE)

#Creamos otro df para trabajor con él 

df <- df_original

#Ver que hay en el df
df_aa <- pjpv.curso.R.2022::pjp_dicc(df)
df_bb <- pjpv.curso.R.2022::pjp_valores_unicos(df, nn = 400)

#Vamos a hacer un poco de limpieza
obj_buenos <- c("df", "df_original", "df_bb")
rm(list = setdiff(ls(), obj_buenos))

#Vamos a seguir arreglando el df

df <- df |> 
  rename(year = time_code) |> 
  rename(PIB_pc = values) |> 
  rename(country = geo)

#Chain linked volumes (2010), euro per capita

#Solo queremos el PIB_pc
df <- df |> 
  filter(unit == "Chain linked volumes (2010), euro per capita")
  
#Eliminamos todo lo que nos molesta a la vista 
df <- df |> 
  select(-c(unit_code, values_code, unit, time, na_item_code, na_item, flags))

df <- df %>% mutate(year =  as.numeric(year))

df <- df %>% mutate(iso_2_code =  eurostat::harmonize_country_code(geo_code))

df <- df |> 
  select(-c(geo_code, flags_code))

library(fs)
dir_create("datos_pulidos")

#A continuación vamos a exportar los datos para luego importarlas más fácilmente #library(rio)

export(df, "./datos_pulidos/PIB_pc.csv", type = "csv")

#IMORTAR DATOS INE----
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

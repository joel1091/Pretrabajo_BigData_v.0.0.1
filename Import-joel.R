#Paquetes preliminares----

library(tidyverse)
library(fs)
library(rio)


#----
#----
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

df <- df |>  mutate(year =  as.numeric(year))

df <- df |>  mutate(iso_2_code =  eurostat::harmonize_country_code(geo_code))

df <- df |> 
  select(-c(geo_code, flags_code))

library(fs)
dir_create("datos_pulidos") 

#A continuación vamos a exportar los datos para luego importarlas más fácilmente #library(rio)

export(df, "./datos_pulidos/PIB_pc.csv", type = "csv")

#----
#----
#IMPORTAR DATOS FRED / MALOS, RENTA----
df_FRED <- import("https://fred.stlouisfed.org/graph/fredgraph.csv?bgcolor=%23e1e9f0&chart_type=line&drp=0&fo=open%20sans&graph_bgcolor=%23ffffff&height=450&mode=fred&recession_bars=off&txtcolor=%23444444&ts=12&tts=12&width=718&nt=0&thu=0&trc=0&show_legend=yes&show_axis_titles=yes&show_tooltip=yes&id=PCAGDPESA646NWDB,NYGDPPCAPKDUSA&scale=left,left&cosd=1960-01-01,1960-01-01&coed=2022-01-01,2022-01-01&line_color=%234572a7,%23aa4643&link_values=false,false&line_style=solid,solid&mark_type=none,none&mw=3,3&lw=2,2&ost=-99999,-99999&oet=99999,99999&mma=0,0&fml=a,a&fq=Annual,Annual&fam=avg,avg&fgst=lin,lin&fgsnd=2020-02-01,2020-02-01&line_index=1,2&transformation=lin,lin&vintage_date=2023-12-14,2023-12-14&revision_date=2023-12-14,2023-12-14&nd=1960-01-01,1960-01-01")


df_long <- gather(df_FRED, key = "Country", value = "PIB_pc", -DATE) |> 
  rename(year = DATE)

#ARREGLAR EL FORMATO DE YEAR

df_long$year <- substr(df_long$year, 1, 4)

#Arreglamos los nombres de los paises

df_done <- df_long |> 
  mutate(Country = str_replace(Country, "PCAGDPESA646NWDB", "España")) |> 
  mutate(Country = str_replace(Country, "NYGDPPCAPKDUSA", "Estados_Unidos")) |> 
  mutate(year =  as.numeric(year))
  




#export(df_FRED, "./datos_pulidos/PIB_pc_FRED.csv", type = "csv")

#----
#----
#IMPORTAR DATOS INE + LIMPIEZA----

#DATOS SOBRE EL SALARIO POR NIVEL DE FORMACIÓN

library(rio)
library(tidyverse)
url <- "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/13931.csv?nocab=1"
df_ine <- import(url)
df_ine_01 <- df_ine |> 
  filter(Decil %in% ("Total decil")) |> 
  select("Periodo", "Tipo de jornada", "NIVELES DE FORMACION", "Total") |> 
  rename(year = Periodo) |> 
  rename(jornada = 'Tipo de jornada') |> 
  rename(formacion = 'NIVELES DE FORMACION') |>
  rename(salario = Total)
    
export(df_ine_01,"./datos_pulidos/salario_formacion.csv", type = "csv")

#
#
#

#DATOS SOBRE EL SALARIO POR EDADES

url_1 <- "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/13928.csv?nocab=1"
df_ine_x1 <- import(url_1)

df_ine_02 <- df_ine_x1 |> 
  filter(Decil %in% ("Total decil")) |>
  select("Periodo", "Tipo de jornada", "Grupo de edad", "Total") |> 
  rename(year = Periodo) |> 
  rename(jornada = 'Tipo de jornada') |> 
  rename(grupo_edad = 'Grupo de edad') |>
  rename(salario = Total)
  
export(df_ine_02,"./datos_pulidos/salario_grupo_edad.csv", type = "csv")

#
#
#

#DATOS SOBRE EL IPC

url_2 <- "https://www.ine.es/jaxiT3/files/t/es/csv_bdsc/50908.csv?nocab=1"
df_ipc <- import(url_2)

df_ipc_01 <- df_ipc |> 
  filter(`Grupos ECOICOP` %in% c("Índice general", "04 Vivienda, agua, electricidad, gas y otros combustibles")) |> 
  select("Periodo", "Grupos ECOICOP", "Tipo de dato", "Total") |> 
  rename(year = Periodo) |>
  rename(grupo = 'Grupos ECOICOP') |> 
  rename(tipo_dato = `Tipo de dato` )

#PARA SEPARAR EN LA VARIABLE YEAR LOS DATOS POR AÑOS Y MESES
df_sep <- df_ipc_01 |> 
  separate(col = year, into = c("year", "month"), sep = "M")

df_sep <- df_sep |> 
  mutate(month = paste0("M", month))

export(df_sep, "./datos_pulidos/IPC_mas_vivienda.csv", type = "csv")
#----
#----
#EMPEZAMOS CON LAS PRUEBAS DE GRÁFICAS -- EUROSTAT-----
library(tidyverse)
library(ggplot2)

df_original<-read.csv("./datos_pulidos/PIB_pc.csv")

df <- df_original |>
  select(-c(iso_2_code))

df <- df |>
  filter(country %in% unique(df$country[df$PIB_pc > 23000 & df$year == 2015]) & !grepl("^Euro", country))

#Utilizo la función !grepl para eliminar los paises que empiezen por Euro

ggplot(df, aes(x = year, y = PIB_pc, color = country)) +
  geom_line()+
  geom_point()

df_spain <- df_original |> 
  filter(country == "Spain")

p_spain <- ggplot(df_spain, aes(x = year, y = PIB_pc, color = country)) +
  geom_line()+
  geom_point()
p_spain


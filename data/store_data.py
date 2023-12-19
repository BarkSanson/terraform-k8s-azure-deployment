# Read MOCK_DATA.csv

import csv
import os
from pathlib import Path
DATA_2022 = csv.reader(open(os.path.join(Path(__file__).parent.absolute(), "FIFA20.csv"), "r"), delimiter=",")
# DATA_2020_2021 = csv.reader(open(os.path.join(Path(__file__).parent.absolute(), "flight_logs_2020_2021.csv"), "r"), delimiter=",")

# Skip header
next(DATA_2022)
# next(DATA_2020_2021)

# def write_flights_csv(f, data):
#     f.write(("INSERT INTO flight_logs "
#             "(flight_number, departure_airport, " \
#             "arrival_airport, departure_date, "\
#             "arrival_date, departure_time, "\
#             "arrival_time, passenger_count) VALUES\n"))
#     for row in data:
#         departure_airport = row[1]
#         arrival_airport = row[2]
#         if departure_airport == '0':
#             departure_airport = 'PMI'
#         if arrival_airport == '0':
#             arrival_airport = 'MAD'
#         f.write(f"('{row[0]}', '{departure_airport}', '{arrival_airport}', '{row[3]}', '{row[4]}', '{row[5]}', '{row[6]}', {row[7]}),\n")
    
#     f.write(";\n\n")


# with open(os.path.join(Path(__file__).parent.absolute(), "db.sql"), "a") as f:
#     write_flights_csv(f, DATA_2022)
#     write_flights_csv(f, DATA_2020_2021)

DATA_FIFA = csv.reader(open(os.path.join(Path(__file__).parent.absolute(), "FIFA20.csv"), errors="ignore"), delimiter=",")

# Skip header
next(DATA_FIFA)

def es_correcto(n: str):
   bol = True
   
   n = ''.join(n.split()) #quitamos los espacios para analizar el nombre
   for char in n:
       if not str.isalpha(char) and not char == '.': # si el caracter del nombre no es ni alfabetico ni el punto
           bol = False
   
   return bol

with open(os.path.join(Path(__file__).parent.absolute(), "db.sql"), "a") as f:
   f.write(("INSERT INTO jugador "
           "(id, nom, " \
           "edad, overall, nacionalidad) VALUES\n"))
   

   #número de jugadores a analizar
   #He decidido escoger los atributos de nombre, edad, pais, i pie. Con esta información se podria pensar de hacer algun gráfico
   limit = 2000

   for row in DATA_FIFA:
       id = row[0]
       nom = row[1]
       edad = row[2]
       nacionalidad = row[4]
       overall = row[7]

       # me fijé que algunos jugadores tenian un carácter erróneo en el nombre
       # algunos caracteres del nombre de algunos jugadores no era alfabético (sin contar el '.' i los espacios)
       # ejemplo -> nombre = '16 Maicon'
       # he decidido descartar estos jugadores. Esto es por simplicidad ya que hay otros nombres que llevan caracteres como ' que 
       # no son alfabeticos pero que pertenecen al nombre.
       if(es_correcto(nom)):
          
           f.write(f"({id}, '{nom}', {edad}, '{overall}', '{nacionalidad}'),\n")

       limit -= 1

       if limit == 0:
           break
   
   f.write(";\n\n")




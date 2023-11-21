extensions [
  py
]

breed [stations station] ;Crear familia de estaciones de la calle 26
breed [autobuss autobus ]         ;Crear familia de articulados
breed [peoples people]   ;Crear familia de personas

globals [
  clock                      ; operations' system clock - unit:seconds
  pas_sim                    ; 1/10 s
  step                       ; 0.4 in both directions x and y
]

stations-own [
  stop_id	
  stop_code	
  stop_name	
  location_type	
  parent_station
]

autobuss-own [
  ruta_id         ;Identificador de la ruta que el autobús sigue, obtenido de trips.txt
  posicionEnRuta  ;Posición actual del autobús en su ruta. Puede ser un índice que corresponda a la secuencia de paradas
  ParadaArray ;La próxima parada en la ruta del autobús
  enParada        ;Indica si el autobús está actualmente en una parada
  start_time
  status
  tiempoDeEspera   ; Contador de tiempo de espera en la estación
  siguienteParada
]

peoples-own [

]

to set_up
  clear-all
  py:setup py:python3
  ; py:setup "C:/Users/USUARIO/Anaconda3/envs/NetLogo/python" ---
  ;;Otras opciones:
      ;;py:setup py:python  ; if your code works with either Python 2 or 3
      ;;py:setup py:python3 ; for Python 3
      ;;py:setup py:python2 ; for Python 2

  ;;; importing python packages
  (py:run
    "import pandas as pd"
    "import numpy as np"
    "path = '/Users/monicaperez/Documents/Tesis Analitica/'" ;Change this to extract the files que estan en una carpeta
    )

  ;;; global variables initial values
  set clock 0                 ; assuming the first movement not part of the system
  set pas_sim 0.1             ; each tick corresponds to 0.1 s
  set step 0.4                ; step defined after setting the distances and times in between machines and nodes

    ;;; enviroment declarations
  ask patches [set pcolor blue - 1.8]
  create-stations 57

  set-uplayout
  setup-autobuses

  reset-ticks

end

to go
  move
  enter_system
  stop_in_station
  move_in_station
  avance_clock
  tick

end

to avance_clock
  set clock precision (clock + pas_sim) 1
end

to move
  ask autobuss with [status = "moving" ][
    fd step
    ;; correcting the decimal values
  ]
end

to enter_system
  if any? autobuss with [status = "not"][
    ask autobuss with [(status = "not") and (start_time <= clock)][
      ;; Encuentra la estación correspondiente al primer stop_id en la lista ParadaArray
      let first_stop_id item 0 ParadaArray
      let target_station one-of stations with [stop_code = first_stop_id]
      ;; Mueve el autobús a la estación
      if target_station != nobody [
        move-to target_station
        ;; Elimina el primer stop_id ya que el autobús está ahora en esa parada
        set status "waiting"
        set posicionEnRuta posicionEnRuta + 1
        set siguienteParada target_station
      ]
    ]
  ]
end


to move_in_station

    ask autobuss [
    if status = "waiting" [
      set tiempoDeEspera tiempoDeEspera - 1
      ; Verificar si el autobús ha terminado de esperar
      if tiempoDeEspera <= 0 [
        if not empty? ParadaArray [
          ; Obtener el stop_id de la siguiente parada
          let next_stop_id item posicionEnRuta ParadaArray

          ; Encontrar la estación correspondiente y moverse hacia ella
          let target_station one-of stations with [stop_code = next_stop_id]
          if target_station != nobody [
            face target_station
            ; Actualizar la lista de paradas y establecer el tiempo de espera
            set posicionEnRuta posicionEnRuta + 1
            set tiempoDeEspera 20  ; Establecer el tiempo de espera para la próxima parada
            set status "moving"
            set siguienteParada target_station
          ]
        ]
      ]
    ]
  ]

end

to stop_in_station

  ask stations [
    let current_station self  ; Guardar la estación actual para la comparación
    let pasando autobuss-here with [status = "moving" and siguienteParada = current_station]
    ask pasando [
      if tiempoDeEspera > 0 [
        set status "waiting"
      ]
    ]
  ]

end


to set-uplayout

  ;;Construir el layout de las estaciones
  (py:run
    "nodes_xy = pd.read_excel(f'{path}estaciones1.xlsx')"
    "who = nodes_xy['who'].tolist()"
    "xcor = nodes_xy['x_scaled'].tolist()"
    "ycor = nodes_xy['y_scaled'].tolist()"
    "stop_id	=  nodes_xy['stop_id'].tolist()"
    "stop_code = nodes_xy['stop_code'].tolist()"
    "stop_name = nodes_xy['stop_name'].tolist()"
    "location_type = nodes_xy['location_type'].tolist()"	
    "parent_station = nodes_xy['parent_station'].tolist()"
  )

  let whomm py:runresult "who"
  let xcorm py:runresult "xcor"
  let ycorm py:runresult "ycor"
  let gg py:runresult "stop_id"
  let hh py:runresult "stop_code"
  let ii py:runresult "stop_name"
  let jj py:runresult "location_type"
  let kk py:runresult "parent_station"


  (foreach whomm xcorm ycorm gg hh ii jj kk[[a d f g h i j k] ->
    ask stations with [who = a][
      set xcor d
      set ycor f
      set stop_id	g
      set stop_code h	
      set stop_name	i
      set location_type j	
      set parent_station k
      set label i
      set shape "container"
      set color grey
      set size 10
    ]
  ])

end

to setup-autobuses

  (py:run
    "trips_data = pd.read_excel(f'{path}trips_numerico-f.xlsx')"
    "bus_trip_ids = trips_data['trip_id'].tolist()"
    "bus_route_ids = trips_data['route_id'].tolist()"
    "aa = trips_data['route_short_name'].tolist()"	
    "bb = trips_data['route_long_name'].tolist()"	
    "cc = trips_data['stops_array'].tolist()"
    "dd = trips_data['arrive'].tolist()"
  )

  let bus_trip_ids_list py:runresult "bus_trip_ids"
  let bus_route_ids_list py:runresult "bus_route_ids"
  Let bu_aa py:runresult "aa"
  let bus_bb py:runresult "bb"
  let bus_cc py:runresult "cc"
  let bus_dd py:runresult "dd"

  ;; Crear autobuses basados en los viajes (trips) de GTFS
  (foreach bus_trip_ids_list bus_route_ids_list bu_aa bus_bb bus_cc bus_dd [[trip_id route_id a1 b1 c1 d1] ->
    create-autobuss 1 [
      set color red
      set shape "train passenger car"
      set ruta_id route_id
      set posicionEnRuta 0
      set ParadaArray c1
      set ParadaArray read-from-string ParadaArray
      set enParada false
      set label a1
      ;; Define la posición inicial y otros atributos según necesites
      set xcor 100
      set ycor 0
      set status "not"
      set tiempoDeEspera 0
      set start_time d1
      set size 9
    ]
  ])
end
@#$#@#$#@
GRAPHICS-WINDOW
82
28
1292
539
-1
-1
2.0
1
10
1
1
1
0
0
0
1
0
600
0
250
0
0
1
ticks
30.0

BUTTON
105
51
178
84
NIL
set_up
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
106
89
169
122
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 false 60 135 60 165
Line -7500403 false 60 120 60 165
Line -7500403 false 90 120 90 165
Line -7500403 false 120 120 120 165
Line -7500403 false 150 120 150 165
Line -7500403 false 180 120 180 165
Line -7500403 false 210 120 210 165
Line -7500403 false 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 false 257 120 257 207

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

container
false
0
Rectangle -7500403 false false 0 75 300 225
Rectangle -7500403 true true 0 75 300 225
Line -16777216 false 0 210 300 210
Line -16777216 false 0 90 300 90
Line -16777216 false 150 90 150 210
Line -16777216 false 120 90 120 210
Line -16777216 false 90 90 90 210
Line -16777216 false 240 90 240 210
Line -16777216 false 270 90 270 210
Line -16777216 false 30 90 30 210
Line -16777216 false 60 90 60 210
Line -16777216 false 210 90 210 210
Line -16777216 false 180 90 180 210

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

train passenger car
false
0
Polygon -7500403 true true 15 206 15 150 15 135 30 120 270 120 285 135 285 150 285 206 270 210 30 210
Circle -16777216 true false 240 195 30
Circle -16777216 true false 210 195 30
Circle -16777216 true false 60 195 30
Circle -16777216 true false 30 195 30
Rectangle -16777216 true false 30 140 268 165
Line -7500403 true 60 135 60 165
Line -7500403 true 60 135 60 165
Line -7500403 true 90 135 90 165
Line -7500403 true 120 135 120 165
Line -7500403 true 150 135 150 165
Line -7500403 true 180 135 180 165
Line -7500403 true 210 135 210 165
Line -7500403 true 240 135 240 165
Rectangle -16777216 true false 5 195 19 207
Rectangle -16777216 true false 281 195 295 207
Rectangle -13345367 true false 15 165 285 173
Rectangle -2674135 true false 15 180 285 188

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

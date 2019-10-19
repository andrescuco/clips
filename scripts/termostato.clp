(deftemplate correccion-temperatura 
-40 40 
( 
(negativa (-10 0) (-6 1) (-4 1) (0 0))
(positiva (0 0) (4 1) (6 1) (10 0))
(muy-negativa (-40 1) (-10 1) (-6 0))
(muy-positiva (6 0) (10 1) (40 1))
))

(deftemplate indice-luminosidad
0 10
(
(bajo (0 0) (2 1) (4 1) (8 0))
(alto (2 0) (6 1) (8 1) (10 0))
))

(deftemplate diferencia-temp
-40 40 
( 
(negativa (-10 0) (-6 1) (-4 1) (0 0))
(positiva (0 0) (4 1) (6 1) (10 0))
(muy-negativa (-40 1) (-10 1) (-6 0))
(muy-positiva (6 0) (10 1) (40 1))
))

(defrule R1 (indice-luminosidad alto)=>(assert(correccion-temperatura negativa)))
(defrule R2 (indice-luminosidad bajo)=>(assert(correccion-temperatura positiva)))
(defrule R3 (diferencia-temp muy-positiva)=>(assert(correccion-temperatura positiva)))
(defrule R4 (diferencia-temp muy-negativa)=>(assert(correccion-temperatura negativa)))

;El usuario define los valores desde consola 
(defrule R0
=>
(printout t "valor de la temperatura del termostato = " )
(bind ?t (read))
(assert (valor-temp-termostato ?t))

(printout t "valor de la temperatura real = " )
(bind ?tr (read))
(assert (valor-temp-real ?tr))

(bind ?dt (- ?tr ?t))
(assert (valor-diferencia-temp ?dt))

(printout t "valor del índice de luminosidad = " )
(bind ?il (read))
(assert (valor-indice-luminosidad ?il))

)

;Se convierten los valores crisp a conjuntos difusos para que las reglas puedan ser utilizadas
(defrule Fuzzify-valores
(and (valor-indice-luminosidad ?il) (valor-diferencia-temp ?dt))
=>
(bind ?dt1 (- ?dt 1))	
(bind ?dt2 (+ ?dt 1))
(assert (diferencia-temp (?dt1 0) (?dt 1) (?dt2 0)))
(bind ?il1 (- ?il 1))
(bind ?il2 (+ ?il 1))
(assert (indice-luminosidad (?il1 0) (?il 1) (?il2 0)))

)
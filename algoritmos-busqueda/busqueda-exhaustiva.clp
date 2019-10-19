;http://www.comp.rgu.ac.uk/staff/smc/teaching/clips/vol1/vol1-Contents.html

(defglobal 
?*ESTADO-INICIAL* = (create$ h1 aspiradora sucia h2 sucia)
?*LISTA* = (create$   (implode$ ?*ESTADO-INICIAL*))
 ?*PADRE* = ?*ESTADO-INICIAL*
 ?*OPERADORES* = (create$ A I D)
 ?*SECUENCIA-DE-OPERADORES* = (create$)
 ?*VISITADOS* = (create$)
 ?*PASOS* = 8
 ?*SOLUCIONES* = (create$)
 ?*COSTE* = (create$ "0")
 ?*SOLUCIONES-COSTE* = (create$)
)

;Sistema-aspiradora: lista (h1 aspiradora sucia h2 sucia)

;Es una función que devuelve h1 y su contenido

(deffunction extrae-h1 ($?estado)
(bind ?posicion-h2 (member$ h2 ?estado))
(subseq$ ?estado 1 (- ?posicion-h2 1))
)

;Es una función que devuelve h2 y su contenido

(deffunction extrae-h2 ($?estado)
(bind ?posicion-h2 (member$ h2 ?estado))
(bind ?ultima (length$ ?estado))
(subseq$ ?estado  ?posicion-h2 ?ultima)
)

;Si la aspiradora esta en la habitación indicada, aspira, si no, no hace nada

(deffunction aspirar ($?habitacion)
(bind ?pos-aspiradora (member$ aspiradora ?habitacion))
(bind ?pos-sucia (member$ sucia ?habitacion))
(if (and ?pos-aspiradora ?pos-sucia) then 
(delete$ ?habitacion ?pos-sucia ?pos-sucia) else ?habitacion)
)

;Si hay una aspiradora en la habitación la quita, si no, no hace nada 

(deffunction quitar-aspiradora ($?habitacion)
(bind ?pos-aspiradora (member$ aspiradora ?habitacion))
(if ?pos-aspiradora  
	then (delete$ ?habitacion ?pos-aspiradora ?pos-aspiradora) 
	else ?habitacion)
)

;Si no hay una aspiradora en la habitación la pone, si no, no hace nada 

(deffunction poner-aspiradora ($?habitacion)
(if (member$ aspiradora ?habitacion) then ?habitacion
else 
(create$ (first$ ?habitacion) aspiradora (rest$ ?habitacion))
)
)

;Comprueba si la habitación esta limpia (TRUE/FALSE)

(deffunction habitacion-limpia? ($?habitacion)
(not(member$ sucia ?habitacion))
)

;Si ambas habitaciones estan limpias devuelve TRUE, si no, FALSE

(deffunction exito ($?estado)
  (bind ?h1 (extrae-h1 ?estado))
  (bind ?h2 (extrae-h2 ?estado))
(and (habitacion-limpia? ?h1) (habitacion-limpia? ?h2)))

;Aspira la habitación en donde hay aspiradoras

(deffunction A ($?estado)
  (bind ?h1 (aspirar(extrae-h1 ?estado)))
  (bind ?h2 (aspirar(extrae-h2 ?estado)))
  (create$ ?h1 ?h2))

;Si la aspiradora esta en h2, la quita y la pone en h1

(deffunction I ($?estado)
  (bind ?h1 (poner-aspiradora(extrae-h1 ?estado)))
  (bind ?h2 (quitar-aspiradora(extrae-h2 ?estado)))
  (create$ ?h1 ?h2))

;Si la aspiradora esta en h1, la quita y la pone en h2

(deffunction D ($?estado)
  (bind ?h1 (quitar-aspiradora(extrae-h1 ?estado)))
  (bind ?h2 (poner-aspiradora(extrae-h2 ?estado)))
  (create$ ?h1 ?h2))

;Comprueba si el estado esta prohibido

(deffunction prohibido? ($?estado)
(eq $?estado PROHIBIDO)
)

;Esta función aplica el operador indicado sobre el estado dado 

(deffunction aplicar-operador (?operador $?estado)
(eval
(format nil "( %s (create$ %s))" ?operador (implode$ ?estado))
)
)

;Dado un estado te devuelve los operadores que puedes aplicar sobre el (por falta de la definición de prohibido, no funciona correctamente)

(deffunction operadores-hijos($?estado)
(bind $?lista-operadores (create$))
(progn$ (?op ?*OPERADORES*) 
	(bind $?hijo (aplicar-operador ?op ?estado))
	(if (not (prohibido? ?hijo)) then 
		(bind ?lista-operadores (create$ ?lista-operadores ?op))))
?lista-operadores)

;Devuelve todos los estados posibles aplicando los operadores disponibles

(deffunction hijos($?estado)
(bind $?lista-hijos (create$))
(progn$ (?op ?*OPERADORES*) 
	(bind $?hijo (aplicar-operador ?op ?estado))
	(if (not (prohibido? ?hijo)) then 
		(bind ?lista-hijos (create$ ?lista-hijos (implode$  ?hijo))))
))

;Esta función realiza las operaciones necesarias para complentar una busqueda en profundiad e imprime los resultados 

(deffunction busqueda-en-profundidad ($?lista)
(bind ?i 0)
(while (and(not (exito ?*PADRE*)) (not (eq ?*LISTA* (create$)))) do
	(printout t "Paso " ?i crlf)
	(bind ?*PADRE*  (explode$(nth$ 1  ?*LISTA*)))
	(printout t "Padre " ?*PADRE* crlf)
	(bind ?*LISTA*(rest$ ?*LISTA*))
	(if (not (exito ?*PADRE*)) then 
		(bind ?operadores-hijos (operadores-hijos ?*PADRE*))
		(bind ?hijos (hijos ?*PADRE*))
 		(bind ?*LISTA* (create$ (hijos ?*PADRE*)   ?*LISTA*)))
	(bind ?i (+ ?i 1))
	(if (and (> ?*PASOS* 0) (= ?i ?*PASOS*)) then (break))
)

(if  (exito ?*PADRE*) then (printout t "La solución es " ?*PADRE* crlf)
else (if (=(length$ ?*LISTA*)0)  then (printout t "No hay solución" crlf)))
)

(deffunction busqueda-en-profundidad-con-visitados ($?lista)
(bind ?i 0)
(while (and(not (exito ?*PADRE*)) (not (eq ?*LISTA* (create$)))) do
	(bind ?*PADRE*  (explode$(nth$ 1  ?*LISTA*)))
	(bind ?*LISTA*(rest$ ?*LISTA*)) 
	(if (not (member$ (implode$ ?*PADRE*) ?*VISITADOS*)) then 
		(printout t "Paso " ?i crlf)
		(printout t "Padre " ?*PADRE* crlf)
		(bind ?*VISITADOS* (create$ ?*VISITADOS* (implode$ ?*PADRE*))) 
		(bind ?operadores-hijos (operadores-hijos ?*PADRE*))
		(bind ?hijos (hijos ?*PADRE*))
 		(bind ?*LISTA* (create$ (hijos ?*PADRE*)   ?*LISTA*))
		(bind ?i (+ ?i 1)))
	(if (and (not (exito ?*PADRE*)) (> ?*PASOS* 0) (= ?i ?*PASOS*)) then (break))
)

(if  (exito ?*PADRE*) then (printout t "La solución es " ?*PADRE* crlf)
else (if (=(length$ ?*LISTA*)0)  then (printout t "No hay solución" crlf)))
)

(deffunction busqueda-en-anchura($?lista)
(bind ?i 0)
(while (and(not (exito ?*PADRE*)) (not (eq ?*LISTA* (create$)))) do
	(printout t "Paso " ?i crlf)
	(bind ?*PADRE*  (explode$(nth$ 1  ?*LISTA*)))
	(printout t "Padre " ?*PADRE* crlf)
	(bind ?*LISTA*(rest$ ?*LISTA*))
	(if (not (exito ?*PADRE*)) then 
		(bind ?operadores-hijos (operadores-hijos ?*PADRE*))
		(bind ?hijos (hijos ?*PADRE*))
 		(bind ?*LISTA* (create$ ?*LISTA* (hijos ?*PADRE*)  )))
	(bind ?i (+ ?i 1))
	(if (and (> ?*PASOS* 0) (= ?i ?*PASOS*)) then (break))
)

(if  (exito ?*PADRE*) then (printout t "La solución es " ?*PADRE* crlf)
else (if (=(length$ ?*LISTA*)0)  then (printout t "No hay solución" crlf)))
)

(deffunction busqueda-en-anchura-con-visitados ($?lista)
(bind ?i 0)
(while (and(not (exito ?*PADRE*)) (not (eq ?*LISTA* (create$)))) do
	(bind ?*PADRE*  (explode$(nth$ 1  ?*LISTA*)))
	(bind ?*LISTA*(rest$ ?*LISTA*)) 
	(if (not (member$ (implode$ ?*PADRE*) ?*VISITADOS*)) then 
		(printout t "Paso " ?i crlf)
		(printout t "Padre " ?*PADRE* crlf)
		(bind ?*VISITADOS* (create$ ?*VISITADOS* (implode$ ?*PADRE*))) 
		(bind ?operadores-hijos (operadores-hijos ?*PADRE*))
		(bind ?hijos (hijos ?*PADRE*))
		(bind ?*LISTA* (create$ ?*LISTA* (hijos ?*PADRE*)  ))
		(bind ?i (+ ?i 1)))
	(if  (and (> ?*PASOS* 0) (= ?i ?*PASOS*)) then (break))
)

(if  (exito ?*PADRE*) then (printout t "La solución es " ?*PADRE* crlf)
else (if (=(length$ ?*LISTA*)0)  then (printout t "No hay solución" crlf)))
)


(deffunction busqueda-exhaustiva-general (?profoanch ?british ?visitados $?lista)
(bind ?i 0)
(while (and (or ?british (not (exito ?*PADRE*))) (not (eq ?*LISTA* (create$)))) do
	(bind ?*PADRE*  (explode$(nth$ 1  ?*LISTA*)))
	(bind ?*LISTA*(rest$ ?*LISTA*)) 
	(if (not (member$ (implode$ ?*PADRE*) ?*VISITADOS*)) then 
		(printout t "Paso " ?i crlf)
		(printout t "Padre " ?*PADRE* crlf)
		(if ?visitados then
			(bind ?*VISITADOS* (create$ ?*VISITADOS* (implode$ ?*PADRE*)))) 
		(bind ?operadores-hijos (operadores-hijos ?*PADRE*))
		(bind ?hijos (hijos ?*PADRE*))
		(if (not (exito ?*PADRE*))then
			(if ?profoanch then
				(bind ?*LISTA* (create$ (hijos ?*PADRE*)   ?*LISTA*)) else
				(bind ?*LISTA* (create$ ?*LISTA* (hijos ?*PADRE*)))) else
			(bind ?*SOLUCIONES* (create$ ?*SOLUCIONES* ?*PADRE*)))
		(bind ?i (+ ?i 1)))
	(if  (and (> ?*PASOS* 0) (= ?i ?*PASOS*)) then (break))
)

(if  (not (eq ?*SOLUCIONES* (create$))) then (printout t "Las soluciónes son: " ?*SOLUCIONES* crlf)
else (if (=(length$ ?*LISTA*)0)  then (printout t "No hay solución" crlf)))
)

(deffunction g1 (?operador)
	1)

(deffunction evaluar-operadores (?actual ?g $?operadores)
	(bind ?coste (create$))
	(while (not (eq ?operadores (create$)))
		(bind ?costeop (+ ?actual (funcall ?g (nth$ 1 $?operadores))))
		(bind ?coste (create$ ?costeop ?coste))
		(bind ?operadores (rest$ $?operadores))
	)
	?coste
)

(deffunction busca-min ($?lista)
	(bind ?i 0)
	(bind ?min (string-to-field(str-cat(nth$ 1 $?lista))))	
	(bind ?mini 1)
	(while (not(eq $?lista (create$)))
		(bind ?i (+ ?i 1))
		(bind ?prim (string-to-field(str-cat(nth$ 1 $?lista))))
		(if (< ?prim ?min) then
			(bind ?min ?prim)
			(bind ?mini ?i))
		(bind $?lista (rest$ $?lista)))
	?mini)

(deffunction busqueda-british-prof-mejor (?g $?lista)
(bind ?i 0)
(while (not (eq ?*LISTA* (create$))) do
	(bind ?*PADRE*  (explode$(nth$ 1  ?*LISTA*)))
	(bind ?*LISTA* (rest$ ?*LISTA*)) 
	(bind ?actual_coste (string-to-field(str-cat(nth$ 1 ?*COSTE*))))
	(bind ?*COSTE* (rest$ ?*COSTE*))
	(if (not (member$ (implode$ ?*PADRE*) ?*VISITADOS*)) then 
		(printout t "Paso " ?i crlf)
		(printout t "Padre " ?*PADRE* crlf)
		(printout ?actual_coste)
		(bind ?*VISITADOS* (create$ ?*VISITADOS* (implode$ ?*PADRE*)))
		(bind ?operadores-hijos (operadores-hijos ?*PADRE*))
		(bind ?hijos (hijos ?*PADRE*))
		(if (not (exito ?*PADRE*)) then
			(bind ?*LISTA* (create$ (hijos ?*PADRE*)   ?*LISTA*))
			(bind ?*COSTE* (create$ (evaluar-operadores ?actual_coste ?g ?operadores-hijos) ?*COSTE*))
		else
			(bind ?*SOLUCIONES* (create$ ?*SOLUCIONES* (implode$ ?*PADRE*)))
			(bind ?*SOLUCIONES-COSTE* (create$ ?*SOLUCIONES-COSTE* ?actual_coste)))
			
		(bind ?i (+ ?i 1)))
	(if  (and (> ?*PASOS* 0) (= ?i ?*PASOS*)) then (break))
)

(if  (not (eq ?*SOLUCIONES* (create$))) then 
	(printout t "Las soluciónes son: " ?*SOLUCIONES* crlf) 
	(bind ?mejor (nth$ (busca-min ?*SOLUCIONES-COSTE*) ?*SOLUCIONES*))
	(printout t "La mejor sulción está:" ?mejor crlf)
else (if (=(length$ ?*LISTA*)0)  then (printout t "No hay solución" crlf)))

)
 



















(defglobal
?*suma* = 0
)

(deftemplate rectangulo 
	(slot ancho) 
	(slot alto))

(deftemplate circulo 
	(slot radio))

(deftemplate triangulo 
	(slot lado1) 
	(slot lado2) 
	(slot lado3))

(deftemplate area-total 
	(slot circulos) 
	(slot rectangulos) 
	(slot triangulos) 
	(slot suma-areas))

(deffacts formas
(triangulo (lado1 5) (lado2 7) (lado3 8))
(rectangulo (ancho 5) (alto 7))
;(rectangulo (ancho 3) (alto 6))
(circulo (radio 4)))

(defrule area-triangulo 
	(triangulo 
		(lado1 ?x) 
		(lado2 ?y) 
		(lado3 ?z))
	=> 
	(bind ?s (/ (+ ?x ?y ?z) 2))
	(bind ?at (sqrt (* ?s (- ?s ?x) (- ?s ?y) (- ?s ?z))))	
	(assert (area-del-triangulo (sqrt (* ?s (- ?s ?x) (- ?s ?y) (- ?s ?z)))))
	(bind ?*suma* (+ ?*suma* ?at))
	)

(defrule area-rectangulo 
	(rectangulo 
		(ancho ?x) 
		(alto ?y)) 
	=> 
	(bind ?ar (* ?x ?y))
	(assert (area-del-rectangulo (* ?x ?y)))
	(bind ?*suma* (+ ?*suma* ?ar))
	)

(defrule area-circulo 
	(circulo 
		(radio ?x)) 
	=> 
	(bind ?ac (* ?x 3.1416))
	(assert (area-del-circulo (* ?x 3.1416)))
	(bind ?*suma* (+ ?*suma* ?ac))
	)
	
(defrule suma-areas
	(declare (salience -10))
	=>
	(printout t "La suma de todas las areas es: "
				?*suma*
				crlf)
	)

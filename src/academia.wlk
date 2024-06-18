object acme {
	method utilidad(cosa) = cosa.volumen() / 2
}

object fenix {
	method utilidad(cosa) = if (cosa.esReliquia()) 	3 else 	0
}

object cuchuflito {
	method utilidad(cosa)  = 0
}

class Cosa {
	const property marca
	const property volumen
	const property esMagico
	const property esReliquia

	method utilidad() = volumen + self.plusMagico() + self.plusReliquia() + marca.utilidad(self)
	method plusMagico() = if (esMagico) 3 else 0
	method plusReliquia() = if (esReliquia) 5 else 0
}

class Mueble {
	const property cosas = #{}

	method puedeGuardar(cosa)
	method contiene(cosa) = cosas.contains(cosa)
	method utilidad() = cosas.sum({ cosa => cosa.utilidad() }) / self.precio() //2.1
	method precio()
	method menosUtil() = cosas.min({ cosa => cosa.utilidad() })

	method guardar(cosa) {
		cosas.add(cosa)
	}
	method remover(cosa) {
		cosas.remove(cosa)
	}
}

class Baul inherits Mueble {
	var property capacidadMaxima

	method volumenUsado() = cosas.sum({ cosa => cosa.volumen() })
	override method puedeGuardar(cosa) = cosa.volumen() + self.volumenUsado() < capacidadMaxima
	override method precio() = capacidadMaxima + 2
	override method utilidad() = super() + if(self.guardaSoloReliquias()) 2 else  0
	method guardaSoloReliquias() = cosas.all({ cosa => cosa.esReliquia() })
}

class BaulMagico inherits Baul {

	override method precio() = super() * 2
	override method utilidad() =  super() + self.bonusPorElementosMagicos()
	method bonusPorElementosMagicos() = cosas.count({ cosa => cosa.esMagico() })
}

class GabineteMagico inherits Mueble {
	var property precio

	override method puedeGuardar(cosa) =  cosa.esMagico()
}

class ArmarioConvencional inherits Mueble {
	var property capacidadMaxima

	override method puedeGuardar(cosa) = cosas.size() < capacidadMaxima
	override method precio() =  5 * capacidadMaxima
}

class Academia {
	var property muebles = #{}

	method puedeGuardar(cosa) = self.algunMueblePuedeGuardar(cosa) and not self.yaExisteEnAlgunMueble(cosa)
	method yaExisteEnAlgunMueble(cosa) = muebles.any({ mueble => mueble.contiene(cosa) })					 //1.1
	method dondeEsta(cosa) =  muebles.find({ mueble => mueble.contiene(cosa) }) 		 					 //1.2
	method algunMueblePuedeGuardar(cosa)= muebles.any({ mueble => mueble.puedeGuardar(cosa) }) 				 //1.3
	method dondePuedeGuardar(cosa) = muebles.filter({ mueble => mueble.puedeGuardar(cosa) }) 				 //1.4	
	method guardar(cosa) { 																					 //1.5
		self.verificar(cosa)
		self.dondePuedeGuardar(cosa).asList().first().guardar(cosa)
	}
	method menosUtiles() = muebles.map({ mueble => mueble.menosUtil() }).asSet()  							 //2.2
	method marcaMenosUtil() = self.menosUtiles().min({ cosa => cosa.utilidad() }).marca()  					 //2.3
	method removerMenosUtilesNoMagicos() {																	 //2.4
		self.validarHaySuficientesMuebles()
		self.menosUtilesNoMagicos().forEach({ cosaARemover =>
			const mueble = self.dondeEsta(cosaARemover)
			mueble.remover(cosaARemover)
		})
	}
	method validarHaySuficientesMuebles() {
		if (muebles.size() < 3) {
			self.error("Tiene que haber al menos tres muebles para poder remover")
		}
	}
	method menosUtilesNoMagicos() = self.menosUtiles().filter({ cosa => not cosa.esMagico() })
	method verificar(cosa) {
		if (not self.puedeGuardar(cosa)) self.error("No se puede guardar")
	}
}

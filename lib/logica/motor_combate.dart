import 'personaje.dart';
import 'momia.dart';
import 'motor_fisica.dart';

enum ResultadoColisionMomia { ninguna, momiaDerrotada, jugadorGolpeado }

class MotorCombate {
  static ResultadoColisionMomia resolverColision(Personaje personaje, Momia momia) {
    if (momia.derrotada) return ResultadoColisionMomia.ninguna;

    final alineadoEnX = personaje.x < momia.x + momia.ancho &&
        personaje.x + personaje.ancho > momia.x;
    final pie = personaje.y + personaje.alto;
    final caeEnMitadSuperior = personaje.velocidadY > 0 &&
        alineadoEnX &&
        pie >= momia.y &&
        pie <= (momia.y + momia.alto / 2);

    if (caeEnMitadSuperior) {
      momia.derrotada = true;
      personaje.velocidadY = MotorFisica.impulsoSalto / 2; // rebote
      return ResultadoColisionMomia.momiaDerrotada;
    }

    if (!personaje.rectangulo.intersectaCon(momia.rectangulo)) {
      return ResultadoColisionMomia.ninguna;
    }

    return ResultadoColisionMomia.jugadorGolpeado;
  }
}

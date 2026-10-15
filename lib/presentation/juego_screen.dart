import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../logica/motor_juego.dart';
import '../logica/personaje.dart';
import '../logica/momia.dart';
import '../logica/calaverita.dart';
import '../logica/rectangulo.dart';
import '../logica/estado_juego.dart';

class JuegoScreen extends StatefulWidget {
  const JuegoScreen({super.key});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> {
  late MotorJuego _motor;
  Timer? _bucle;
  double _direccion = 0;

  // Control por teclado
  final FocusNode _focusNode = FocusNode();
  bool _teclaIzquierda = false;
  bool _teclaDerecha = false;

  @override
  void initState() {
    super.initState();
    _iniciarNivel();
    _iniciarBucle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  void _iniciarNivel() {
    _motor = MotorJuego(
      personaje: Personaje(x: 20, y: 100),
      plataformas: const [
        Rectangulo(x: 0, y: 300, ancho: 2000, alto: 40),
        Rectangulo(x: 300, y: 220, ancho: 120, alto: 20),
        Rectangulo(x: 550, y: 160, ancho: 120, alto: 20),
      ],
      momias: [
        Momia(x: 320, y: 268, limiteIzquierdo: 300, limiteDerecho: 420),
        Momia(x: 900, y: 268, limiteIzquierdo: 850, limiteDerecho: 1100),
      ],
      calaveritas: [
        Calaverita(x: 360, y: 180),
        Calaverita(x: 600, y: 120),
        Calaverita(x: 1200, y: 260),
      ],
      posicionMeta: 1900,
      anchoNivel: 2000,
    );
    _teclaIzquierda = false;
    _teclaDerecha = false;
    _direccion = 0;
  }

  void _iniciarBucle() {
    _bucle?.cancel();
    _bucle = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() => _motor.mover(_direccion * 4));
      if (_motor.estado != EstadoJuego.jugando) {
        _bucle?.cancel();
        _mostrarResultado();
      }
    });
  }

  @override
  void dispose() {
    _bucle?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _actualizarDireccionTeclado() {
    if (_teclaIzquierda && !_teclaDerecha) {
      _direccion = -1;
    } else if (_teclaDerecha && !_teclaIzquierda) {
      _direccion = 1;
    } else {
      _direccion = 0;
    }
  }

  KeyEventResult _manejarTeclado(FocusNode node, KeyEvent event) {
    final esPresionar = event is KeyDownEvent || event is KeyRepeatEvent;
    final esSoltar = event is KeyUpEvent;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      if (esPresionar) _teclaIzquierda = true;
      if (esSoltar) _teclaIzquierda = false;
      _actualizarDireccionTeclado();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowRight || key == LogicalKeyboardKey.keyD) {
      if (esPresionar) _teclaDerecha = true;
      if (esSoltar) _teclaDerecha = false;
      _actualizarDireccionTeclado();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.keyW ||
        key == LogicalKeyboardKey.space) {
      if (event is KeyDownEvent) {
        _motor.saltar();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _mostrarResultado() {
    final gano = _motor.estado == EstadoJuego.ganado;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'resultado',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) => ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
        child: FadeTransition(
          opacity: anim1,
          child: AlertDialog(
            backgroundColor: const Color(0xFF1F132B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: gano ? const Color(0xFFFFD54F) : const Color(0xFFE91E63),
                width: 2,
              ),
            ),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(gano ? '💋 ' : '💀 '),
                Flexible(
                  child: Text(
                    gano ? '¡Llegaste al Callejón del Beso!' : 'Las momias te atraparon',
                    style: TextStyle(
                      color: gano ? const Color(0xFFFFE082) : const Color(0xFFFF8A80),
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gano
                    ? '¡Felicidades explorador! Cruzaste los callejones de Guanajuato con éxito.'
                    : 'Las momias legendarias te alcanzaron. ¡Inténtalo de nuevo!',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Puntaje final:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text(
                        '💀 ${_motor.puntaje}',
                        style: const TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD81B60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(_iniciarNivel);
                  _iniciarBucle();
                  _focusNode.requestFocus();
                },
                icon: const Icon(Icons.replay),
                label: const Text('Jugar de nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchoPantalla = MediaQuery.of(context).size.width;
    final anchoVentana = anchoPantalla > 0 ? anchoPantalla : 360.0;
    final maxCamara = (_motor.anchoNivel - anchoVentana).clamp(0.0, _motor.anchoNivel);
    final camaraX = (_motor.personaje.x - anchoVentana / 2).clamp(0.0, maxCamara.toDouble());

    return Scaffold(
      backgroundColor: const Color(0xFF1A0E2E),
      appBar: AppBar(
        title: const Text('Momias de Guanajuato'),
        backgroundColor: const Color(0xFF381442),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black87,
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _manejarTeclado,
        child: GestureDetector(
          onTap: () => _focusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              // Barra de HUD Superior Estilizada
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E123D), Color(0xFF4A1942)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha:0.3), width: 1.5),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    // Indicador de vidas
                    Row(
                      children: [
                        Text(
                          'Vidas: ${_motor.vidas} ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        ...List.generate(3, (index) {
                          final tieneVida = index < _motor.vidas;
                          return Padding(
                            padding: const EdgeInsets.only(left: 3),
                            child: Icon(
                              tieneVida ? Icons.favorite : Icons.favorite_border,
                              color: tieneVida ? const Color(0xFFFF1744) : Colors.white24,
                              size: 20,
                            ),
                          );
                        }),
                      ],
                    ),

                    // Atajo de teclado (Tooltip visual)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.keyboard, color: Color(0xFFFFD54F), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'A/D o ⬅️➡️ | Espacio o ⬆️',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Puntaje
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF20092B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha:0.5)),
                      ),
                      child: Row(
                        children: [
                          const Text('💀 ', style: TextStyle(fontSize: 15)),
                          Text(
                            'Puntaje: ${_motor.puntaje}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFD54F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

              // Lienzo del Nivel del Juego
              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      // 1. Cielo Crepuscular de Guanajuato (Fondo degradado)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1E0C36), // Púrpura noche alta
                                Color(0xFF4A154B), // Magenta colonial
                                Color(0xFF7A2048), // Bugambilia atardecer
                                Color(0xFFB84D35), // Terracota cálido
                                Color(0xFFE58C43), // Ámbar horizonte
                              ],
                              stops: [0.0, 0.35, 0.6, 0.8, 1.0],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),

                      // 2. Luna colonial y estrellas
                      Positioned(
                        top: 25,
                        right: 60,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFF9C4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFE082).withValues(alpha:0.6),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Estrellas en el cielo
                      ...List.generate(12, (index) {
                        final posX = (index * 160.0 + 35) % 1800;
                        final posY = (index * 27.0 + 15) % 95;
                        return Positioned(
                          left: posX - (camaraX * 0.1),
                          top: posY,
                          child: const Icon(
                            Icons.star,
                            size: 9,
                            color: Color(0x99FFF9C4),
                          ),
                        );
                      }),

                      // 3. Silueta de Cerros y Cúpulas de Guanajuato (Capa de Parallax Lejana)
                      Positioned(
                        bottom: 40,
                        left: - (camaraX * 0.25),
                        child: Row(
                          children: List.generate(6, (i) {
                            return SizedBox(
                              width: 380,
                              height: 120,
                              child: CustomPaint(
                                painter: _SiluetaColonialPainter(
                                  color: const Color(0xFF2C103B).withValues(alpha:0.65),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // 4. Faroles coloniales con luz cálida en el nivel
                      ...[200.0, 500.0, 850.0, 1150.0, 1500.0, 1850.0].map((farolX) => Positioned(
                        left: farolX - camaraX,
                        top: 236,
                        child: Column(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD54F),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFB300).withValues(alpha:0.8),
                                    blurRadius: 16,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.lightbulb, size: 11, color: Color(0xFF5D4037)),
                              ),
                            ),
                            Container(
                              width: 3,
                              height: 46,
                              color: const Color(0xFF212121),
                            ),
                          ],
                        ),
                      )),

                      // 5. Plataformas (Cantera Rosa de Guanajuato esculpida)
                      ..._motor.plataformas.map((pl) => Positioned(
                            left: pl.x - camaraX,
                            top: pl.y,
                            child: Container(
                              width: pl.ancho,
                              height: pl.alto,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE05275), // Cantera rosa superior iluminada
                                    Color(0xFFB83256), // Cuerpo de cantera
                                    Color(0xFF7A1B36), // Sombra inferior de piedra
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFFF8DA1),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: _TexturaCanteraPainter(),
                              ),
                            ),
                          )),

                      // 6. Calaveritas de azúcar 💀 con resplandor dorado
                      ..._motor.calaveritas.where((c) => !c.recolectada).map((c) => Positioned(
                            left: c.x - camaraX,
                            top: c.y,
                            child: Container(
                              width: c.ancho,
                              height: c.alto,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD54F).withValues(alpha:0.7),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Text(
                                '\u{1F480}',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          )),

                      // 7. Momias de Guanajuato 🧟 con sombra
                      ..._motor.momias.where((m) => !m.derrotada).map((m) => Positioned(
                            left: m.x - camaraX,
                            top: m.y,
                            child: Container(
                              width: m.ancho,
                              height: m.alto,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE6D7C3), Color(0xFFBCAAA4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF6D4C41), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text('\u{1F9DF}', style: TextStyle(fontSize: 20)),
                            ),
                          )),

                      // 8. Meta: Callejón del Beso (Balcón Colonial emblemático) 💋
                      Positioned(
                        left: _motor.posicionMeta - camaraX,
                        top: 175,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD81B60),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFE91E63).withValues(alpha:0.6),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('💋 ', style: TextStyle(fontSize: 18)),
                                  Text(
                                    'CALLEJÓN DEL BESO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Balcón colonial con reja y flores
                            Container(
                              width: 80,
                              height: 75,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF3E2723), width: 2),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 14,
                                    color: const Color(0xFFD81B60),
                                    alignment: Alignment.center,
                                    child: const Text('🌸🌺🌸🌺', style: TextStyle(fontSize: 9)),
                                  ),
                                  const Spacer(),
                                  const Text('🚪', style: TextStyle(fontSize: 26)),
                                  const SizedBox(height: 2),
                                  Container(
                                    height: 12,
                                    color: const Color(0xFF212121),
                                    alignment: Alignment.center,
                                    child: const Text('||||||||||', style: TextStyle(color: Colors.amber, fontSize: 8)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 9. Personaje Explorador 🤠
                      Positioned(
                        left: _motor.personaje.x - camaraX,
                        top: _motor.personaje.y,
                        child: Container(
                          width: _motor.personaje.ancho,
                          height: _motor.personaje.alto,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1976D2).withValues(alpha:0.5),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text('\u{1F920}', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controles Táctiles y de Teclado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFF230D35),
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botones Izquierda / Derecha
                    Row(
                      children: [
                        _botonControl(
                          icono: Icons.arrow_back,
                          label: 'A / ⬅️',
                          alPresionar: () => _direccion = -1,
                          alSoltar: () => _direccion = 0,
                        ),
                        const SizedBox(width: 18),
                        _botonControl(
                          icono: Icons.arrow_forward,
                          label: 'D / ➡️',
                          alPresionar: () => _direccion = 1,
                          alSoltar: () => _direccion = 0,
                        ),
                      ],
                    ),

                    // Botón Salto
                    _botonControl(
                      icono: Icons.arrow_upward,
                      label: 'SALTO (Espacio)',
                      esSalto: true,
                      alPresionar: () => _motor.saltar(),
                      alSoltar: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botonControl({
    required IconData icono,
    required String label,
    required VoidCallback alPresionar,
    required VoidCallback alSoltar,
    bool esSalto = false,
  }) {
    return GestureDetector(
      onTapDown: (_) {
        _focusNode.requestFocus();
        alPresionar();
      },
      onTapUp: (_) => alSoltar(),
      onTapCancel: alSoltar,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: esSalto ? 72 : 62,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: esSalto
                    ? const [Color(0xFFE91E63), Color(0xFFC2185B)]
                    : const [Color(0xFF3949AB), Color(0xFF283593)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: esSalto ? const Color(0xFFFF80AB) : const Color(0xFF7986CB),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (esSalto ? const Color(0xFFE91E63) : const Color(0xFF3949AB)).withValues(alpha:0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icono, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Pintor de textura de sillares de cantera
class _TexturaCanteraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha:0.15)
      ..strokeWidth = 1.0;

    // Líneas de bloques de piedra
    for (double x = 40; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    if (size.height > 20) {
      canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pintor de silueta colonial (cúpulas y tejados de Guanajuato)
class _SiluetaColonialPainter extends CustomPainter {
  final Color color;
  _SiluetaColonialPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.7);

    // Cúpula 1
    path.lineTo(size.width * 0.15, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.22, size.height * 0.35,
      size.width * 0.30, size.height * 0.7,
    );

    // Torre/Campanario
    path.lineTo(size.width * 0.38, size.height * 0.7);
    path.lineTo(size.width * 0.38, size.height * 0.25);
    path.lineTo(size.width * 0.44, size.height * 0.25);
    path.lineTo(size.width * 0.44, size.height * 0.7);

    // Tejado colonial
    path.lineTo(size.width * 0.65, size.height * 0.65);
    path.lineTo(size.width * 0.75, size.height * 0.45);
    path.lineTo(size.width * 0.85, size.height * 0.65);

    path.lineTo(size.width, size.height * 0.65);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

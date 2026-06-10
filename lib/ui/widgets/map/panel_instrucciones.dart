import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PanelInstruccionesNeo extends StatefulWidget {
  final String instruccion;
  final double distanciaMetros;
  final IconData icono;
  final String? carril;
  final int? numeroSalida; // NUEVO
  final String? nombreVia;  // NUEVO

  const PanelInstruccionesNeo({
    super.key,
    required this.instruccion,
    required this.distanciaMetros,
    required this.icono,
    this.carril,
    this.numeroSalida,
    this.nombreVia,
  });

  @override
  State<PanelInstruccionesNeo> createState() => _PanelInstruccionesNeoState();
}

class _PanelInstruccionesNeoState extends State<PanelInstruccionesNeo> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isMuted = false;
  String _ultimaInstruccionId = "";
  int _ultimoHitoLeido = -1;

  @override
  void initState() {
    super.initState();
    _configurarTts();
  }

  void _configurarTts() async {
    await _flutterTts.setLanguage("es-ES");
    await _flutterTts.setSpeechRate(0.55);
    await _flutterTts.setVolume(1.0);
  }

  @override
  void didUpdateWidget(covariant PanelInstruccionesNeo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isMuted) return;

    if (widget.instruccion != _ultimaInstruccionId) {
      _ultimaInstruccionId = widget.instruccion;
      _ultimoHitoLeido = -1;
      _hablarInstruccionUltraPrecisa("Nueva");
    } else {
      _verificarHitosDistancia();
    }
  }

  void _verificarHitosDistancia() {
    final d = widget.distanciaMetros;
    if (d <= 20 && _ultimoHitoLeido != 0) {
      _hablarInstruccionUltraPrecisa("Ahora");
      _ultimoHitoLeido = 0;
    } else if (d <= 150 && d > 130 && _ultimoHitoLeido != 150) {
      _hablarInstruccionUltraPrecisa("Hito");
      _ultimoHitoLeido = 150;
    } else if (d <= 600 && d > 580 && _ultimoHitoLeido != 600) {
      _hablarInstruccionUltraPrecisa("Hito");
      _ultimoHitoLeido = 600;
    }
  }

  Future<void> _hablarInstruccionUltraPrecisa(String tipo) async {
    String texto = "";
    String dist = _formatDistanciaParaVoz(widget.distanciaMetros);

    // Lógica de voz para rotondas y salidas
    String maniobra = widget.instruccion;
    if (widget.numeroSalida != null) {
      maniobra = "En la rotonda, tome la salida número ${widget.numeroSalida}";
    }

    if (tipo == "Ahora") {
      texto = "Ahora, $maniobra";
    } else {
      texto = "${tipo == "Nueva" ? "En" : "A"} $dist, $maniobra";
    }

    if (widget.nombreVia != null && tipo == "Nueva") {
      texto += " dirección ${widget.nombreVia}";
    }

    if (widget.carril != null) {
      texto += ". ${widget.carril}";
    }

    await _flutterTts.speak(texto);
  }

  @override
  Widget build(BuildContext context) {
    const Color darkGreen = Color(0xFF064D44);
    const Color neonYellow = Color(0xFFCCFF00);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Stack(
        children: [
          // Sombra Neo-Brutalista
          Positioned.fill(
            top: 6, left: 6,
            child: Container(decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(25))),
          ),

          Container(
            decoration: BoxDecoration(
              color: darkGreen,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.black, width: 2.5),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono dinámico (Si es rotonda, muestra el número dentro)
                _buildIconoComplejo(widget.icono, widget.numeroSalida),
                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.nombreVia != null)
                        Text(widget.nombreVia!.toUpperCase(),
                            style: TextStyle(color: neonYellow, fontWeight: FontWeight.w900, fontSize: 12)),
                      Text(
                        widget.instruccion.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _formatDistanciaDisplay(widget.distanciaMetros),
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                      if (widget.carril != null) _buildCarrilBadge(widget.carril!, neonYellow),
                    ],
                  ),
                ),
                _buildBotonVoz(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconoComplejo(IconData icono, int? salida) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(icono, color: Colors.white, size: 50),
        if (salida != null)
          Positioned(
            top: 12,
            child: Text("$salida",
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
      ],
    );
  }

  Widget _buildBotonVoz() {
    return GestureDetector(
      onTap: () {
        setState(() => _isMuted = !_isMuted);
        if (_isMuted) _flutterTts.stop();
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white, shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2)
        ),
        child: Icon(_isMuted ? Icons.mic_off : Icons.mic, color: Colors.black),
      ),
    );
  }

  // --- MÉTODOS DE SOPORTE ---
  String _formatDistanciaParaVoz(double m) => m >= 1000 ? "${(m/1000).toStringAsFixed(1)} kilómetros" : "${m.round()} metros";
  String _formatDistanciaDisplay(double m) => m >= 1000 ? "${(m/1000).toStringAsFixed(1)} km" : "${m.round()} m";

  Widget _buildCarrilBadge(String t, Color c) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black, width: 1.5)),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10)),
  );
}
import 'package:flutter/material.dart';
import 'package:fl_business/displays/prc_documento_3/view_models/documento_view_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class LocationService extends ChangeNotifier {
  String longitud = "";
  String latitutd = "";
  bool isLocation = false;

  String mensaje = "";

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio de ubicación está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      // No se puede continuar sin servicio de ubicación
      isLocation = false;
      mensaje = 'El servicio de ubicación está desactivado.';
      notifyListeners();
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Solicita permisos
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // El usuario negó los permisos
        isLocation = false;

        mensaje = 'Los permisos de ubicación fueron denegados';
        notifyListeners();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Los permisos fueron denegados para siempre
      isLocation = false;

      mensaje = 'Los permisos de ubicación están denegados permanentemente.';
      notifyListeners();
    }

    // Obtener la ubicación
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getLocation(BuildContext context) async {
    final vm = Provider.of<DocumentoViewModel>(context, listen: false);
    try {
      vm.isLoading = true;
      final position = await determinePosition();

      longitud = "${position.longitude}";
      latitutd = "${position.latitude}";

      isLocation = true;
      vm.isLoading = false;
      notifyListeners();
    } catch (e) {
      mensaje = e.toString();
      vm.isLoading = false;

      isLocation = false;
      notifyListeners();
    }
  }
}

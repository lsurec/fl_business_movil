// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:fl_business/displays/shr_local_config/services/services.dart';
import 'package:fl_business/displays/shr_local_config/view_models/view_models.dart';
import 'package:fl_business/models/models.dart';
import 'package:fl_business/models/url_pic_model.dart';
import 'package:fl_business/providers/logo_provider.dart';
import 'package:fl_business/routes/app_routes.dart';
import 'package:fl_business/services/services.dart';
import 'package:fl_business/shared_preferences/preferences.dart';
import 'package:fl_business/view_models/view_models.dart';
import 'package:fl_business/views/views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class SplashViewModel extends ChangeNotifier {
  //version actual
  static String versionLocal = "";
  static String versionRemota = "";
  static String idDevice = "";
  String idApp = "app_business";

  static const _key = 'device_uuid';
  static final _storage = FlutterSecureStorage();
  static final _uuid = Uuid();

  static Future<void> getOrCreateUuid() async {
    final existing = await _storage.read(key: _key);

    if (existing != null && existing.isNotEmpty) {
      idDevice = existing;
      return;
    }

    final newUuid = _uuid.v4();
    await _storage.write(key: _key, value: newUuid);
    idDevice = newUuid;
  }

  SplashViewModel() {
    _init();
  }

  Future<void> _init() async {
    VersionService versionService = VersionService();
    versionLocal = await versionService.getVersionLocal();
    await getOrCreateUuid();
  }

  double verStrToNum(String versionstr) {
    // Separar la cadena de versión en partes usando el carácter '.'
    List<int> versionParts = versionstr.split('.').map(int.parse).toList();

    // Convertir las partes en un número decimal
    double versionNumber =
        versionParts[0] + versionParts[1] / 100 + versionParts[2] / 10000;

    return versionNumber;
  }

  //cargar datos iniciales
  Future<void> loadData(BuildContext context) async {
    //view models externos
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);
    final localVM = Provider.of<LocalSettingsViewModel>(context, listen: false);

    // Preferences.urlApi = "http://192.168.0.8:3036/api/";

    //serviico controlar version
    VersionService versionService = VersionService();

    versionLocal = await versionService.getVersionLocal();

    //cargar logo guardado
    if (Preferences.logo.isNotEmpty) {
      Provider.of<LogoProvider>(
        context,
        listen: false,
      ).loadLogo(Preferences.token, UrlPicModel(url: ""));
    }

    //TODO: Buscar version remota

    //instancia del servicio

    // ApiResModel res = await versionService.getVersion(
    //   idApp,
    //   versionLocal,
    // );

    // //valid succes response
    // if (!res.succes) {
    //   //si algo salio mal mostrar alerta
    //   NotificationService.showSnackbar("No se pudo comprobar la version");
    // } else {
    //   //asignar la version remota a una variable global
    //   List<VersionModel> versiones = res.message;
    //   //agregar precios encontrados
    //   if (versiones.isEmpty) {
    //     Navigator.of(context).pushReplacement(
    //       MaterialPageRoute(
    //         builder: (context) => UpdateView(
    //           versionRemote: versiones.first,
    //         ),
    //       ),
    //     );
    //     return;

    //     // double vLocal = verStrToNum(versionLocal);
    //     // double vRemmota = verStrToNum(versionRemota);

    //     // if (vRemmota > vLocal) {
    //     //   Navigator.of(context).pushReplacement(
    //     //     MaterialPageRoute(
    //     //       builder: (context) => const UpdateView(),
    //     //     ), // Cambiar a la pantalla principal después de cargar los datos
    //     //   );
    //     //   return;
    //     // }
    //   }
    // }

    //PASOS SPLASH 1: IDIOMA, 2: TEMA, 3: URL, 4: TOKEN 5: ESTACION

    // si no hay un idioma guardado, mostrar pantalla de idioma
    if (Preferences.language.isEmpty) {
      print("1 Idioma");
      Preferences.idLanguage = 0;

      await Future.delayed(const Duration(seconds: 1));
      //mostrar login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LangView(),
        ), // Cambiar a la pantalla principal después de cargar los datos
      );
      return;
    }

    //sino hay tema seleccionado, mostrar pantalla de temas
    if (Preferences.idThemeApp.isEmpty) {
      print("2 Thema");

      await Future.delayed(const Duration(seconds: 1));
      //mostrar login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ThemeView(),
        ), // Cambiar a la pantalla principal después de cargar los datos
      );
      return;
    }

    if (Preferences.urlApi.isEmpty) {
      print("3 Url");
      //si hay un idioma guardado asignarlo a la variable global del idioma
      AppLocalizations.idioma = Locale(Preferences.language);
      // Simula una carga de datos
      await Future.delayed(const Duration(seconds: 1));

      //mostrar pantallaconfiguracion de apis
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ApiView(),
        ), // Cambiar a la pantalla principal después de cargar los datos
      );
      return;
    }

    // si no hay una sesion de usuario guradada
    if (Preferences.token.isEmpty) {
      print("4 Token");
      await Future.delayed(const Duration(seconds: 1));
      //mostrar login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const LoginView(),
        ), // Cambiar a la pantalla principal después de cargar los datos
      );
      return;
    }

    //Si hay sesion y url del api
    //Buscar si hay u token en preferencias
    //si hay uuna sesion asiganr token y usuario global
    loginVM.token = Preferences.token;
    loginVM.user = Preferences.userName;
    loginVM.conStr = Preferences.conStr;

    final String user = loginVM.user;
    final String token = loginVM.token;

    //cargar emmpresas

    final EmpresaService empresaService = EmpresaService();

    final ApiResModel resEmpresas = await empresaService.getEmpresa(
      user,
      token,
    );

    if (!resEmpresas.succes) {
      //si hay mas de una estacion o mas de una empresa mostar configuracion local

      localVM.resApis = resEmpresas;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes
            .shrLocalConfig, // Ruta a la que se redirigirá después de cerrar sesión
        (Route<dynamic> route) => false,
      );

      return;
    }

    final EstacionService estacionService = EstacionService();

    final ApiResModel resEstaciones = await estacionService.getEstacion(
      user,
      token,
    );

    if (!resEmpresas.succes) {
      //si hay mas de una estacion o mas de una empresa mostar configuracion local

      localVM.resApis = resEstaciones;

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes
            .shrLocalConfig, // Ruta a la que se redirigirá después de cerrar sesión
        (Route<dynamic> route) => false,
      );

      return;
    }

    localVM.empresas.addAll(resEmpresas.response);
    localVM.estaciones.addAll(resEstaciones.response);

    if (localVM.estaciones.length == 1) {
      localVM.selectedEstacion = localVM.estaciones.first;
    }

    if (localVM.empresas.length == 1) {
      localVM.selectedEmpresa = localVM.empresas.first;

      if (localVM.selectedEmpresa?.absolutePathPicture == null) {
        NotificationService.showSnackbar("Logo de empresa no asignado");
      } else {
        Uri uriPicture = Uri.parse(
          localVM.selectedEmpresa!.absolutePathPicture,
        );

        if (Preferences.logo != uriPicture.pathSegments.last) {
          Provider.of<LogoProvider>(context, listen: false).loadLogo(
            token,
            UrlPicModel(url: localVM.selectedEmpresa!.absolutePathPicture),
          );
        }
      }
    }

    //si solo hay una estacion y una empresa mostrar home
    if (localVM.estaciones.length == 1 && localVM.empresas.length == 1) {
      //view model externo
      final menuVM = Provider.of<MenuViewModel>(context, listen: false);

      final MenuService menuService = MenuService();

      final ApiResModel resApps = await menuService.getApplication(user, token);

      if (!resApps.succes) {
        //si hay mas de una estacion o mas de una empresa mostar configuracion local

        localVM.resApis = resApps;

        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes
              .shrLocalConfig, // Ruta a la que se redirigirá después de cerrar sesión
          (Route<dynamic> route) => false,
        );

        return;
      }

      final List<ApplicationModel> applications = resApps.response;

      menuVM.menuData.clear();

      for (var application in applications) {
        final ApiResModel resDisplay = await menuService.getDisplay(
          application.application,
          user,
          token,
        );

        if (!resDisplay.succes) {
          //si hay mas de una estacion o mas de una empresa mostar configuracion local

          localVM.resApis = resDisplay;

          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes
                .shrLocalConfig, // Ruta a la que se redirigirá después de cerrar sesión
            (Route<dynamic> route) => false,
          );

          return;
        }

        menuVM.menuData.add(
          MenuData(application: application, children: resDisplay.response),
        );
      }

      menuVM.loadDataMenu(context);

      //navegar a home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeView()),
      );
      return;
    }

    localVM.resApis = null;

    //si hay mas de una estacion o mas de una empresa mostar configuracion local
    Navigator.of(context).pushNamedAndRemoveUntil(
      // Ruta a la que se redirigirá después de cerrar sesión
      AppRoutes.shrLocalConfig,
      // Condición para eliminar todas las rutas anteriores
      (Route<dynamic> route) => false,
    );
  }
}

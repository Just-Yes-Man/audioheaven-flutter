import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'MyAppState.dart';
import 'login_screen.dart';
import 'register_screen.dart'; // Asumo que creas este archivo separado para el registro
import 'LogsPage.dart';
import 'SeguimientoPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  final httpLink = HttpLink('https://audioheaven-graph.onrender.com/graphql/');
  final authLink = AuthLink(getToken: () async => '');
  final link = authLink.concat(httpLink);

  final client = ValueNotifier<GraphQLClient>(
    GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    ),
  );

  runApp(
    GraphQLProvider(
      client: client,
      child: ChangeNotifierProvider(
        create: (_) => MyAppState(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'innSalud',
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Para alternar entre Login y Registro dentro del índice 0
  bool showLogin = true;

  void onLoginSuccess() {
    setState(() {
      // Cambiar a pantalla Seguimiento automáticamente
      final appState = context.read<MyAppState>();
      appState.selectedIndex = 1;
      showLogin = true; // para que si vuelves a Login, esté visible el login y no registro
    });
  }

  void switchToRegister() {
    setState(() {
      showLogin = false;
    });
  }

  void switchToLogin() {
    setState(() {
      showLogin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    Widget page;

    if (appState.selectedIndex == 0) {
      // Mostrar login o registro dentro de la misma pantalla
      page = showLogin
          ? LoginPage(
              onLoginSuccess: onLoginSuccess,
              onSwitchToRegister: switchToRegister,
            )
          : RegisterPage(
              onSwitchToLogin: switchToLogin,
            );
    } else if (appState.selectedIndex == 1) {
      page = SeguimientoPage();
    } else if (appState.selectedIndex == 2) {
      page = LogsPage();
    } else if (appState.selectedIndex == 3) {
  page = LoginPage(
    onLoginSuccess: () {
      
    },
    onSwitchToRegister: () {
      setState(() {
        showLogin = false; 
        appState.selectedIndex = 0; 
      });
    },
  );
}
else {
      throw UnimplementedError('No widget para índice ${appState.selectedIndex}');
    }

    var mainArea = ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            return Column(
              children: [
                Expanded(child: mainArea),
                SafeArea(
                  child: BottomNavigationBar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedItemColor: Theme.of(context).colorScheme.primary,
                    unselectedItemColor: Colors.grey[500],
                    items: const [
                      BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Login'),
                      BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: 'Seguimiento'),
                      BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Historial'),
                      BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Perfil'),
                    ],
                    currentIndex: appState.selectedIndex,
                    onTap: (value) {
                      setState(() {
                        appState.selectedIndex = value;
                        showLogin = true; // Reiniciar a Login cuando se vuelva a índice 0
                      });
                    },
                  ),
                ),
              ],
            );
          } else {
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedIconTheme: IconThemeData(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selectedLabelTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    extended: constraints.maxWidth >= 600,
                    destinations: const [
                      NavigationRailDestination(icon: Icon(Icons.music_note), label: Text('Login')),
                      NavigationRailDestination(icon: Icon(Icons.graphic_eq), label: Text('Seguimiento')),
                      NavigationRailDestination(icon: Icon(Icons.library_music), label: Text('Historial')),
                      NavigationRailDestination(icon: Icon(Icons.account_circle), label: Text('Perfil')),
                    ],
                    selectedIndex: appState.selectedIndex,
                    onDestinationSelected: (value) {
                      setState(() {
                        appState.selectedIndex = value;
                        showLogin = true;
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}

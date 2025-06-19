import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'MyAppState.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onSwitchToRegister;

  const LoginPage({
    required this.onLoginSuccess,
    required this.onSwitchToRegister,
    Key? key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> showAlert({
    required String title,
    required String desc,
    required AlertType type,
  }) {
    return Alert(
      context: context,
      type: type,
      title: title,
      desc: desc,
      style: AlertStyle(
        backgroundColor: Colors.grey[900],
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        descStyle: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Aceptar", style: TextStyle(color: Colors.white)),
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    if (appState.token.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "🎧 Bienvenido, ${appState.username}",
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              onPressed: () {
                appState.logout();
                showAlert(
                  title: "Sesión cerrada",
                  desc: "Has cerrado sesión correctamente.",
                  type: AlertType.info,
                );
              },
            ),
          ],
        ),
      );
    }

    return buildLoginForm(appState);
  }

  Widget buildLoginForm(MyAppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🎵 Inicia sesión", style: TextStyle(fontSize: 22, color: Colors.white)),
            const SizedBox(height: 16),
            TextFormField(
              controller: userNameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Usuario',
                prefixIcon: Icon(Icons.person, color: Colors.white70),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Ingrese su usuario' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock, color: Colors.white70),
              ),
              obscureText: true,
              validator: (value) => value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Iniciar sesión"),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {

                  appState.login(userNameController.text, "token-demo");


     
                  await showAlert(
                    title: "¡Bienvenido!",
                    desc: "Inicio de sesión correcto.",
                    type: AlertType.success,
                  );

                  // Después de cerrar la alerta, llamar el callback
                  widget.onLoginSuccess();
                }
              },
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onSwitchToRegister,
              child: const Text(
                "¿No tienes cuenta? Regístrate",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

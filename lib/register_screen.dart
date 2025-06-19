import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'MyAppState.dart';

const String createPostMutation = """
mutation CreateUser(\$email : String!,  \$password : String!, \$username : String!) {
  createUser(
    email: \$email 
    password: \$password 
    username: \$username 
  ) {
    user {
      id
      email
      username
    }
  }
}
""";

class RegisterPage extends StatefulWidget {
  final VoidCallback onSwitchToLogin;

  const RegisterPage({
    required this.onSwitchToLogin,
    Key? key,
  }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController createEmailController = TextEditingController();
  final TextEditingController createPasswordController = TextEditingController();
  final TextEditingController createUserController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void showAlert({
    required String title,
    required String desc,
    required AlertType type,
  }) {
    Alert(
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

    ThemeData darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.deepPurple,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[900],
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );

    return Theme(
      data: darkTheme,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("🆕 Crear cuenta", style: TextStyle(fontSize: 22, color: Colors.white)),
              const SizedBox(height: 16),
              TextFormField(
                controller: createEmailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email, color: Colors.white70),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: createUserController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nombre de usuario',
                  prefixIcon: Icon(Icons.person_add, color: Colors.white70),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un usuario' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: createPasswordController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white70),
                ),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
              ),
              const SizedBox(height: 20),
              Mutation(
                options: MutationOptions(
                  document: gql(createPostMutation),
                  onCompleted: (result) {
                    if (result != null && result["createUser"] != null) {
                      appState.username = createUserController.text;

                      createEmailController.clear();
                      createUserController.clear();
                      createPasswordController.clear();

                      showAlert(
                        title: "¡Registrado!",
                        desc: "Puedes iniciar sesión ahora.",
                        type: AlertType.success,
                      );
                      widget.onSwitchToLogin(); // Regresar a Login
                    }
                  },
                  onError: (error) {
                    showAlert(
                      title: "Error al crear usuario",
                      desc: error!.graphqlErrors.isNotEmpty
                          ? error.graphqlErrors[0].message
                          : 'Error desconocido',
                      type: AlertType.error,
                    );
                  },
                ),
                builder: (runMutation, result) {
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        runMutation({
                          "email": createEmailController.text,
                          "username": createUserController.text,
                          "password": createPasswordController.text,
                        });
                      }
                    },
                    label: const Text("Crear cuenta"),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: widget.onSwitchToLogin,
                child: const Text(
                  "¿Ya tienes cuenta? Inicia sesión",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

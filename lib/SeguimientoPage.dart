import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'MyAppState.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

String createSongMutation = """
mutation CreateSong(\$url: String!, \$titulo: String!, \$descripcion: String!) {
  createSong(url: \$url, titulo: \$titulo, descripcion: \$descripcion) {
    id
    url
    titulo
    descripcion
  }
}
""";

class SeguimientoPage extends StatelessWidget {
  final TextEditingController urlController = TextEditingController();
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.token.isEmpty) {
      return const Center(
        child: Text('No login yet.'),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bienvenido: ${appState.username}"),
            const SizedBox(height: 20),
            Text("Crear nueva canción"),
            const SizedBox(height: 20),

            // URL
            TextFormField(
              keyboardType: TextInputType.url,
              controller: urlController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[:/.a-zA-Z0-9]")),
              ],
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
                hintText: 'https://example.com/song',
              ),
            ),
            const SizedBox(height: 20),

            // Título
            TextFormField(
              keyboardType: TextInputType.text,
              controller: tituloController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
              ],
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
                hintText: 'Nombre de la canción',
              ),
            ),
            const SizedBox(height: 20),

            // Descripción
            TextFormField(
              keyboardType: TextInputType.text,
              controller: descripcionController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 .,]")),
              ],
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                hintText: 'Breve descripción',
              ),
            ),
            const SizedBox(height: 20),

            // Botón de guardar
            Mutation(
              options: MutationOptions(
                document: gql(createSongMutation),
                update: (cache, result) => cache,
                onCompleted: (result) {
                  if (result == null) {
                    print('Completado con errores');
                  } else {
                    print('Canción creada:');
                    print(result);

                    Alert(
                      context: context,
                      type: AlertType.success,
                      title: appState.username,
                      desc: "Tu canción ha sido registrada correctamente.",
                      buttons: [
                        DialogButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Aceptar",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        )
                      ],
                    ).show();
                  }
                },
                onError: (error) {
                  print('Error:');
                  appState.error = error?.graphqlErrors[0].message ?? "Error desconocido";

                  Alert(
                    context: context,
                    type: AlertType.error,
                    title: appState.username,
                    desc: appState.error,
                    buttons: [
                      DialogButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Aceptar",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      )
                    ],
                  ).show();
                },
              ),
              builder: (runMutation, result) {
                return ElevatedButton(
                  onPressed: () {
                    runMutation({
                      "url": urlController.text,
                      "titulo": tituloController.text,
                      "descripcion": descripcionController.text,
                    });
                  },
                  child: const Text('Guardar canción'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'MyAppState.dart';

// GraphQL Queries
const String query = """
query Songs {
  songs {
    id
    url
    titulo
    descripcion
    totalCount
    comments {
      id
      text
      createdAt
      user {
        username
      }
    }
  }
}
""";

const String createCommentMutation = """
mutation CreateComment(\$songId: Int!, \$text: String!) {
  createComment(songId: \$songId, text: \$text) {
    comment {
      id
      text
      createdAt
      user {
        username
      }
    }
  }
}
""";

const String deleteSongMutation = """
mutation DeleteSong(\$songId: Int!) {
  deleteSong(songId: \$songId) {
    ok
    message
  }
}
""";
Future<void> abrirEnlace(BuildContext context, String url) async {
  final fixedUrl = url.startsWith('http') ? url : 'https://$url';
  final uri = Uri.parse(fixedUrl);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('🌐 Intentando abrir: $fixedUrl')),
  );

  try {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      final msg = '❌ No se pudo abrir el enlace: $fixedUrl (launchUrl retornó false)';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      print(msg);
    }
  } catch (e) {
    final msg = '❌ Error al abrir enlace: $e';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
    print(msg);
  }
}



class LogsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.token.isEmpty) {
      return const Center(
        child: Text('No login yet.'),
      );
    }

    return Query(
      options: QueryOptions(
        document: gql(query),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
      builder: (result, {fetchMore, refetch}) {
        if (result.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (result.hasException) {
          return Center(
            child: Text('Error: ${result.exception.toString()}'),
          );
        }

        final songs = result.data?['songs'] ?? [];

        if (songs.isEmpty) {
          return const Center(
            child: Text("No songs found!"),
          );
        }

        return ListView.builder(
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final id = int.parse(song['id'].toString());
            final url = song['url'] ?? '';
            final titulo = song['titulo'] ?? '';
            final descripcion = song['descripcion'] ?? '';
            final totalCount = song['totalCount'] ?? 0;
            final comments = (song['comments'] as List<dynamic>? ?? []);
             
            String commentsText = comments.isEmpty
                ? "No hay comentarios aún."
                : comments.map((c) {
                    final username = c['user']?['username'] ?? 'Anon';
                    final text = c['text'] ?? '';
                    return '- $username: $text';
                  }).join('\n');

            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (descripcion.isNotEmpty)
                      Text(
                        descripcion,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    const SizedBox(height: 6),
                    GestureDetector(
  onTap: () => abrirEnlace(context, url),
  child: Text(
    url,
    style: const TextStyle(
      fontSize: 14,
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
  ),
),

                    const SizedBox(height: 6),
                    Text(
                      "Votos: $totalCount",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Comentarios:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      commentsText,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    CommentForm(
                      songId: id,
                      onCommentAdded: () {
                        refetch?.call();
                      },
                    ),const SizedBox(height: 12),
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    Mutation(
      options: MutationOptions(
        document: gql(deleteSongMutation),
        onCompleted: (resultData) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resultData?['deleteSong']?['message'] ?? 'Deleted')),
          );
          refetch?.call();
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error?.graphqlErrors.first.message ?? error.toString()}')),
          );
        },
      ),
      builder: (runMutation, mutationResult) {
        return IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          tooltip: 'Eliminar canción',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: const Text('¿Estás seguro de borrar esta canción?'),
                actions: [
                  TextButton(
                    child: const Text('Cancelar'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('Borrar'),
                    onPressed: () {
                      Navigator.pop(context);
                      runMutation({'songId': id});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  ],
),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CommentForm extends StatefulWidget {
  final int songId;
  final VoidCallback onCommentAdded;

  CommentForm({required this.songId, required this.onCommentAdded});

  @override
  _CommentFormState createState() => _CommentFormState();
}

class _CommentFormState extends State<CommentForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(createCommentMutation),
        onCompleted: (_) {
          _controller.clear();
          widget.onCommentAdded();
        },
      ),
      builder: (RunMutation runMutation, QueryResult? result) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Nuevo comentario",
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    runMutation({
                      "songId": widget.songId,
                      "text": text,
                    });
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text("Comentar"),
              ),
            ),
            if (result?.hasException ?? false)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  result!.exception.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        );
      },
    );
  }
}

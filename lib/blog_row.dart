import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

String createVoteMutation = """
mutation CreateVote(\$songId : Int!) {
  createVote(
    songId: \$songId 
  ) {
    song {
      url
      titulo
    }
  }
}
""";

class BlogRow extends StatelessWidget {
  final int id;
  final String url;
  final String description;

  const BlogRow({
    Key? key,
    required this.id,
    required this.url,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'URL: $url',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Descripción: $description',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                ),
                Mutation(
                  options: MutationOptions(
                    document: gql(createVoteMutation),
                    update: (cache, result) => cache,
                    onCompleted: (result) {
                      if (result == null) {
                        print('Completed with errors');
                      } else {
                        print('$id votado');
                        print(result);
                      }
                    },
                    onError: (error) {
                      print('Error:');
                      print(error?.graphqlErrors[0].message);
                    },
                  ),
                  builder: (runMutation, result) {
                    return ElevatedButton(
                      onPressed: () {
                       runMutation({"songId": id});

                      },
                      child: const Text('Like!'),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

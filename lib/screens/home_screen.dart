import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.article),
            SizedBox(width: 10),
            Text('News App', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
      body: FutureBuilder(
        future: _firestore
            .collection('newsArticles')
            .orderBy('newsTitle')
            .limit(1)
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> futureSnapshot) {
          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!futureSnapshot.hasData || futureSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No news articles available.'));
          }

          final firstArticle = futureSnapshot.data!.docs.first;

          return StreamBuilder(
            stream: _firestore.collection('newsArticles').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!streamSnapshot.hasData ||
                  streamSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No news articles available.'));
              }

              final articles = streamSnapshot.data!.docs;

              return ListView.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = index == 0 ? firstArticle : articles[index];

                  return Card(
                    margin: const EdgeInsets.all(15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: article['imageUrl'],
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['newsTitle'],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                article['newsDescription'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Web Scraping Example')),
        body: ArticleList(),
      ),
    );
  }
}

class ArticleList extends StatefulWidget {
  @override
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  List<Map<String, String>> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    scrapeData();
  }

  Future<void> scrapeData() async {
    try {
      final url = 'https://aceh.tribunnews.com/tag/aceh-jaya';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        dom.Document document = parser.parse(response.body);
        
        final articles = document.querySelectorAll('div.article__list');

        List<Map<String, String>> fetchedArticles = [];

        for (var article in articles) {
          final titleElement = article.querySelector('h3.article__title > a');
          final title = titleElement?.text ?? 'No title';
          final link = titleElement?.attributes['href'] ?? 'No link';
          fetchedArticles.add({'title': title, 'link': link});
        }

        setState(() {
          _articles = fetchedArticles;
          _isLoading = false;
        });
      } else {
        print('Failed to load page');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _articles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_articles[index]['title']!),
                subtitle: Text(_articles[index]['link']!),
              );
            },
          );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Kulusiinkut'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class BookPage {
  String image;
  String text;

  BookPage(this.image, this.text);
}

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;
  List _pageTexts = [];
  String url = "https://akuzipik.info/books/Kulusiinkut/book.xml";

  @override
  void initState() {
    super.initState();
    fetchAsset();
    loadAsset();
  }

  // Get path to Documents directory
  Future<String> get _localPath async {
    final directory = await getApplicationCacheDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print(path);
    return File('$path/book.xml');
  }

  // Fetch xml from url and write to local file
  Future<File> fetchAsset() async {
    final file = await _localFile;

    Map<String, String> headers = {"Accept": "text/html,application/xml"};
    final response = await http.get(Uri.parse(url), headers: headers);
    final document = XmlDocument.parse(response.body);
    return file.writeAsString('$document');
  }
  
  Future<void> loadAsset() async {
    List<BookPage> pageList = [];
    final file = await _localFile;
    String fileText = await file.readAsString();//rootBundle.loadString('assets/Kulusiinkut/Kulusiinkut/book.xml');
    final document = XmlDocument.parse(fileText);
    final pages = document.findAllElements('div').where((element) => element.getAttribute('type') == 'page');

    for (var page in pages) {
      final pageText = page.innerText;
      final pageImage = page.findElements('p').first.findElements('graphic').first.getAttribute('url');

      pageList.add(BookPage(pageImage ?? 'no image available', pageText));
    }
    setState(() {
      _pageTexts = pageList;
    });
  }
  
  void _incrementPage() {
    setState(() {
      if (_page < 22) {
        _page++;
      }
    });
  }
  void _decrementPage() {
    setState(() {
      if(_page > 0){
        _page--;
      }
    });
  }
  void _beginPage() {
    setState(() {
      _page = 0;
    });
  }
  void _endPage() {
    setState(()  {
      _page = 22;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementPage method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints (
                maxHeight: 0.8 * screenHeight,
                maxWidth: screenWidth
              ),
              child: 
                _page == 0
                  ? const Image(image: AssetImage('assets/Kulusiinkut/Kulusiinkut/img/100/preview.webp'))
                  : Image(image: AssetImage('assets/Kulusiinkut/Kulusiinkut/img/100/${_pageTexts[_page-1].image}')) 
            ),
            Text(
              _page == 0 ? 'Kulusiinkut'
              :'$_page. ${_pageTexts[_page-1].text}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _beginPage,
                      child: const Text("|<"),
                    ),
                    ElevatedButton(
                      onPressed: _decrementPage,
                      child: const Text("<-"),
                    ),
                    ElevatedButton(
                      onPressed: _incrementPage,
                      child: const Text("->"),
                    ),
                    ElevatedButton(
                      onPressed: _endPage,
                      child: const Text(">|"),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}

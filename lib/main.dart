import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:collection/collection.dart';

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
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

class _MyHomePageState extends State<MyHomePage> {
  int _page = 0;
  List _pageTexts = [];

  @override
  void initState() {
    super.initState();
    loadAsset();
  }
  
  Future<void> loadAsset() async {
    final pageList = [];
    String fileText = await rootBundle.loadString('assets/Kulusiinkut/Kulusiinkut/book.xml');
    final document = XmlDocument.parse(fileText);
    final bookBody = document.findElements('TEI').first.findElements('text').first.findElements('body').first;
    final pages = bookBody.findAllElements('div');

    for (var page in pages) {
      final pageText = page.innerText;

      final pageP = page.findElements('p').firstOrNull;
      String? pageImage;
      if(pageP != null) {
        final pageGraphic = pageP.findElements('graphic').firstOrNull;
        if(pageGraphic != null){
          pageImage = pageGraphic.getAttribute('url');
        }
      }
      pageList.add({'image': pageImage ?? 'no image available', 'text': pageText});
    }
    setState(() {
      _pageTexts = pageList;
    });
  }
  

  void _incrementPage() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _page without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
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
        /*
        child: Column(
          children: _fileContents.entries.map((entry) {
            return Text(
              'Page ${entry.key}: ${entry.value}',
              style: Theme.of(context).textTheme.bodyLarge,
            );
          }).toList(),
        ),*/
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
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
                  : Image(image: AssetImage('assets/Kulusiinkut/Kulusiinkut/img/100/${_pageTexts[_page]['image']}')) 
                  //p${_page.toString().padLeft(4, '0')}.webp
            ),
            Text(
              '$_page. ${_pageTexts[_page]['text']}',
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

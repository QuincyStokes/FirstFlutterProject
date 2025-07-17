import 'package:first_flutter_project/finished_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SecondPage(title: 'Second Page'),
    );
  }
}

class SecondPage extends StatefulWidget {
  const SecondPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  @override
  State<SecondPage> createState() => _MySecondPageState();
}

class ToppingButton extends StatefulWidget {
  final String label;
  final bool initiallyOn;
  final ValueChanged<bool> onChanged;
  const ToppingButton({
    required this.label,
    required this.initiallyOn,
    required this.onChanged,
    super.key,
  });

  @override
  State<ToppingButton> createState() => _ToppingButtonState();
}

class _ToppingButtonState extends State<ToppingButton> {
  late bool _isOn;

  @override
  void initState() {
    super.initState();
    _isOn = widget.initiallyOn;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _isOn ? Colors.blue : Colors.white,
        foregroundColor: _isOn ? Colors.white : Colors.black,
        side: const BorderSide(color: Colors.black12),
      ),
      onPressed: () => {
        setState(() => _isOn = !_isOn),
        widget.onChanged(_isOn),
      },
      child: Text(widget.label),
    );
  }
}

class _MySecondPageState extends State<SecondPage> {
  final List<String> toppings = [
    'Pepperoni',
    'Sausage',
    'Pineapple',
    'Ham',
    'Bacon',
    'Peppers',
    'Olives',
    'Anchovies',
  ];

  final Set<String> _selected = {}; //track which toppings we select

  void _onToppingToggle(String topping, bool isOn) {
    setState(() {
      if (isOn) {
        _selected.add(topping);
      } else {
        _selected.remove(topping);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  Image(
                    image: NetworkImage(
                      "https://slice-menu-assets-prod.imgix.net/15035/1646979120_41495185f2",
                    ),
                    width: 400,
                    height: 400,
                  ),
                  Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: toppings.map((t) {
                          return ToppingButton(
                            label: t,
                            initiallyOn: _selected.contains(t),
                            onChanged: (isOn) => _onToppingToggle(t, isOn),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,

                children: [
                  ElevatedButton(
                    onPressed: () async {
                      print('⏩ Next button pressed');
                      try {
                        final docRef = await FirebaseFirestore.instance
                            .collection('orders')
                            .add({
                              'toppings': _selected.toList(),
                              'timestamp': FieldValue.serverTimestamp(),
                            });
                        print('✅ Order saved: ${docRef.id}');
                      } catch (e, st) {
                        print('❌ Firestore error: $e\n$st');
                      }

                      // now navigate
                      print('⏩ About to navigate');
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SummaryPage(selectedToppings: _selected.toList()),
                        ),
                      );
                    },
                    child: const Text("Next"),
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

import 'package:flutter/material.dart';

class ListWithFadeInItems extends StatefulWidget {
  const ListWithFadeInItems({super.key});

  @override
  ListWithFadeInItemsState createState() => ListWithFadeInItemsState();
}

class ListWithFadeInItemsState extends State<ListWithFadeInItems> {
  final List<int> _items = [];
  final List<bool> _opacityFlags = []; // Controlla l'opacità per ogni elemento
  bool _isAdding = false; // Evita aggiunte concorrenti
  int _nextItem = 0;

  Future<void> _addItemsWithFadeIn() async {
    if (_isAdding) return; // Blocca richieste multiple
    setState(() {
      _isAdding = true;
    });

    for (int i = 0; i < 50; i++) {
      await Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          _items.add(_nextItem++);
          _opacityFlags.add(false); // Inizialmente invisibile
        });

        // Attiva l'animazione di dissolvenza dopo un breve ritardo
        Future.delayed(Duration(milliseconds: 50), () {
          setState(() {
            _opacityFlags[_opacityFlags.length - 1] = true; // Diventa visibile
          });
        });
      });
    }

    setState(() {
      _isAdding = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _addItemsWithFadeIn(); // Aggiunge i primi 50 elementi all'avvio
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista con Apparizione Graduale'),
      ),
      body: ListView.builder(
        itemCount: _items.length + 1, // Include il bottone come ultimo elemento
        itemBuilder: (context, index) {
          if (index == _items.length) {
            // Bottone alla fine della lista
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _isAdding ? null : _addItemsWithFadeIn,
                  child: _isAdding
                      ? CircularProgressIndicator()
                      : Text('Aggiungi altri 50 elementi'),
                ),
              ),
            );
          }

          // Elementi della lista con dissolvenza
          return AnimatedOpacity(
            opacity: _opacityFlags[index] ? 1.0 : 0.0,
            duration: Duration(milliseconds: 500), // Durata della dissolvenza
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: Text('Elemento ${_items[index]}'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'data_service.dart';
import 'widgets.dart';
import 'my_home_page_controller.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _jsonData = '';
  String _selectedUso = '00';
  String _selectedTarda = '00';
  String _date = "";

  @override
  void initState() {
    super.initState();
    _loadCache(); // Carga la caché al inicializar el estado
  }

  Future<void> _loadCache() async {
    final dataService = DataService();
    final cacheResult = await dataService.loadCache();
    setState(() {
      _jsonData = cacheResult['jsonData'];
      _date = cacheResult['date'];
    });
    if (cacheResult['shouldFetchData']) {
      _fetchData(); // Si es necesario, obtiene los datos actualizados
    }
  }

  Future<void> _fetchData() async {
    final dataService = DataService();
    final fetchResult = await dataService.fetchData();
    setState(() {
      _jsonData = fetchResult['jsonData'];
      _date = fetchResult['date'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPreUsage = filterDataPreUsage(_jsonData, _selectedUso); // Filtra los datos según la hora de uso seleccionado
    final filteredNCheapest = filterDataNCheapest(
      filteredPreUsage,
      _selectedTarda, // Filtra los datos según las horas que tarda
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Card(
              elevation: 4.0,
              margin: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      ' $_date \n A que hora me cuesta menos cargar mis baterías:\n',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...buildDropdowns(_selectedUso, _selectedTarda, (uso, tarda) {
                    setState(() {
                      _selectedUso = uso;
                      _selectedTarda = tarda; // Actualiza los valores seleccionados
                    });
                  }),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(10.0),
                    child: Card(
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Text('Las mejores horas del día son:'),
                            ...filteredNCheapest.map((item) {
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text(item), // Muestra las horas más económicas
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _jsonData.split('\n').length,
              itemBuilder: (context, index) {
                final item = _jsonData.split('\n')[index];
                final priceString = item.split(' ')[0];
                final price =
                    double.tryParse(priceString.replaceAll('€/kWh,', '')) ??
                    0.0;
                Color cardColor;
                if (price < 0.10) {
                  cardColor = Colors.green[100]!;
                } else if (price >= 0.10 && price < 0.15) {
                  cardColor = Colors.yellow[100]!;
                } else {
                  cardColor = Colors.red[100]!;
                }
                return Card(
                  color: cardColor,
                  elevation: 4.0,
                  margin: const EdgeInsets.all(10.0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

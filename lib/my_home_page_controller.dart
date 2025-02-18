// my_home_page_controller.dart

// Esta función filtra los datos JSON de entrada según el tiempo de uso seleccionado.
// Devuelve una lista de cadenas donde la hora es menor o igual al tiempo de uso seleccionado.
List<String> filterDataPreUsage(String jsonData, String selectedUso) {
  return jsonData.split('\n').where((item) {
    final hourString = item.split(' ')[2];
    final hour = int.tryParse(hourString) ?? 0;
    return hour <= int.parse(selectedUso);
  }).toList();
}

// Esta función filtra los datos pre-uso para encontrar las N entradas más baratas según el tiempo seleccionado.
// Ordena los datos por precio y luego por hora, devolviendo las N entradas más baratas.
List<String> filterDataNCheapest(
  List<String> filteredPreUsage,
  String selectedTarda,
) {
  filteredPreUsage.sort((a, b) {
    final priceA =
        double.tryParse(a.split(' ')[0].replaceAll('€/kWh,', '')) ?? 0.0;
    final priceB =
        double.tryParse(b.split(' ')[0].replaceAll('€/kWh,', '')) ?? 0.0;
    return priceA.compareTo(priceB);
  });
  final nCheapest = filteredPreUsage.sublist(0, int.parse(selectedTarda));
  nCheapest.sort((a, b) {
    final hourA = int.tryParse(a.split(' ')[2]) ?? 0;
    final hourB = int.tryParse(b.split(' ')[2]) ?? 0;
    return hourA.compareTo(hourB);
  });
  return nCheapest;
}

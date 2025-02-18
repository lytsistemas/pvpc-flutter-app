import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:js/js_util.dart' as js_util;

class DataService {
  // Carga los datos en caché y determina si se deben obtener nuevos datos
  Future<Map<String, dynamic>> loadCache() async {
    bool shouldFetchData = true;
    String jsonData = '';
    DateTime? lastUpdate;
    DateTime? date;
    String dateStr = '';

    if (kIsWeb) {
      // Obtiene los datos almacenados en localStorage si está en la web
      final localStorage = js_util.getProperty(
        js_util.globalThis,
        'localStorage',
      );
      final cachedData = js_util.getProperty(localStorage, 'jsonData');
      final cachedDate = js_util.getProperty(localStorage, 'lastUpdate');
      final cachedDateOnly = js_util.getProperty(localStorage, 'date');
      if (cachedData != null &&
          cachedData.isNotEmpty &&
          cachedDate != null &&
          cachedDate.isNotEmpty &&
          cachedDateOnly != null &&
          cachedDateOnly.isNotEmpty &&
          DateTime.tryParse(cachedDate) != null &&
          DateTime.tryParse(cachedDateOnly) != null) {
        lastUpdate = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(cachedDate);
        date = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(cachedDateOnly);
        dateStr = DateFormat('dd/MM/yyyy').format(date);
        if (DateTime.now().difference(lastUpdate).inHours < 23) {
          jsonData = cachedData;
          shouldFetchData = false;
        }
      }
    } else {
      // Obtiene los datos almacenados en SharedPreferences si no está en la web
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('jsonData');
      final cachedDate = prefs.getString('lastUpdate');
      final cachedDateOnly = prefs.getString('date');
      if (cachedData != null &&
          cachedData.isNotEmpty &&
          cachedDate != null &&
          cachedDate.isNotEmpty &&
          cachedDateOnly != null &&
          cachedDateOnly.isNotEmpty &&
          DateTime.tryParse(cachedDate) != null &&
          DateTime.tryParse(cachedDateOnly) != null) {
        lastUpdate = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(cachedDate);
        if (DateTime.now().difference(lastUpdate).inHours < 23) {
          date = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").parse(cachedDateOnly);
          dateStr = DateFormat('dd/MM/yyyy').format(date);
          jsonData = cachedData;
          shouldFetchData = false;
        }
      }
    }

    return {
      'jsonData': jsonData,
      'shouldFetchData': shouldFetchData,
      'date': dateStr,
    };
  }

  // Obtiene los datos de la API y los almacena en caché
  Future<Map<String, dynamic>> fetchData() async {
    final response = await http.get(
      Uri.parse('https://api.esios.ree.es/indicators/1001'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      DateTime lastUpdate = DateFormat(
        "yyyy-MM-ddTHH:mm:ss.SSSZ",
      ).parse(data['indicator']['values_updated_at']);

      DateTime? date;

      final filteredData =
          data['indicator']['values']
              .where((item) => item['geo_id'] == 8741)
              .map((item) {
                date ??= DateFormat(
                  "yyyy-MM-ddTHH:mm:ss.SSSZ",
                ).parse(item['datetime']);
                final datetime = DateFormat(
                  "yyyy-MM-ddTHH:mm:ss.SSSZ",
                ).parse(item['datetime']);
                final hour = datetime.hour.toString().padLeft(2, '0');
                final priceInKwh = (item['value'] / 1000).toStringAsFixed(3);
                return '$priceInKwh €/kWh, $hour h';
              })
              .toList();
      final jsonData = filteredData.join('\n');

      if (kIsWeb) {
        // Almacena los datos en localStorage si está en la web
        final localStorage = js_util.getProperty(
          js_util.globalThis,
          'localStorage',
        );
        js_util.setProperty(localStorage, 'jsonData', jsonData);
        js_util.setProperty(
          localStorage,
          'lastUpdate',
          lastUpdate.toIso8601String(),
        );
        js_util.setProperty(localStorage, 'date', date!.toIso8601String());
      } else {
        // Almacena los datos en SharedPreferences si no está en la web
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('jsonData', jsonData);
        prefs.setString('lastUpdate', lastUpdate.toIso8601String());
        prefs.setString('date', date!.toIso8601String());
      }

      return {
        'jsonData': jsonData,
        'lastUpdate': lastUpdate,
        'date': DateFormat('dd/MM/yyyy').format(date!),
      };
    } else {
      throw Exception('Failed to load data');
    }
  }
}

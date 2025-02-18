import 'package:flutter/material.dart';

// Función para construir una lista de widgets de menú desplegable
List<Widget> buildDropdowns(
  String selectedUso, // Hora seleccionada para "Las necesito a las:"
  String selectedTarda, // Hora seleccionada para "Tardan en cargarse:"
  Function(String, String) onSelected, // Función de callback cuando se selecciona un valor del menú desplegable
) {
  return [
    // Fila para el primer menú desplegable
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownMenu<String>(
          label: const Text('Las necesito a las:'), // Etiqueta para el primer menú desplegable
          initialSelection: selectedUso, // Valor seleccionado inicialmente para el primer menú desplegable
          onSelected: (value) {
            onSelected(value!, '00'); // Callback con el valor seleccionado y '00' por defecto para el segundo menú desplegable
          },
          dropdownMenuEntries: List.generate(24, (index) {
            final hour = index.toString().padLeft(2, '0'); // Formatear la hora con un cero a la izquierda
            return DropdownMenuEntry(value: hour, label: '$hour horas'); // Entrada del menú desplegable para cada hora
          }),
        ),
      ],
    ),
    const SizedBox(height: 20), // Espacio entre los menús desplegables
    // Fila para el segundo menú desplegable
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownMenu<String>(
          label: const Text('Tardan en cargarse:'), // Etiqueta para el segundo menú desplegable
          initialSelection: "00", // Valor seleccionado inicialmente para el segundo menú desplegable
          onSelected: (value) {
            onSelected(selectedUso, value!); // Callback con los valores seleccionados para ambos menús desplegables
          },
          dropdownMenuEntries: List.generate(int.parse(selectedUso) + 1, (
            index,
          ) {
            final hour = index.toString().padLeft(2, '0'); // Formatear la hora con un cero a la izquierda
            return DropdownMenuEntry(value: hour, label: '$hour horas'); // Entrada del menú desplegable para cada hora
          }),
        ),
      ],
    ),
  ];
}

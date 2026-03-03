import 'package:flutter/material.dart';

class AddSmartCardScreen extends StatelessWidget {
  const AddSmartCardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Smart Card / Tag'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          body: ListView(
            controller: controller,
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTextField(label: 'Resident Name', hint: 'e.g., Rajesh Kumar'),
              _buildTextField(label: 'Unit / Flat', hint: 'e.g., Unit B-1204'),
              _buildDropdownField(label: 'Card Type', items: ['RFID Tag', 'NFC Card']),
              _buildTextField(label: 'Card Number', hint: 'e.g., SC-PH-1204'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[400], minimumSize: const Size.fromHeight(50)),
                child: const Text('Issue Smart Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({required String label, required String hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          DropdownButtonFormField(
            value: items.first,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }
}

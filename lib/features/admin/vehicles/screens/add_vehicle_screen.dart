import 'package:flutter/material.dart';

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Add Vehicle'),
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
              _buildTextField(label: 'Vehicle Number', hint: 'e.g., TS09ER1234'),
              _buildDropdownField(label: 'Vehicle Type', items: ['3 Wheeler', '4 Wheeler', '2 Wheeler']),
              _buildDropdownField(label: 'Residency Status', items: ['Owner', 'Tenant']),
              const SizedBox(height: 16),
              const Text('Flat Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              _buildTextField(label: 'Building/Block', hint: 'e.g., Block A, Tower 1'),
              Row(
                children: [
                  Expanded(child: _buildTextField(label: 'Floor', hint: 'e.g., 12')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(label: 'Flat No.', hint: 'e.g., 1204')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('This is an Electric Vehicle (EV)'),
                  Switch(value: false, onChanged: (value) {}),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Vehicle'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], minimumSize: const Size.fromHeight(50)),
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
            initialValue: items.first,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }
}

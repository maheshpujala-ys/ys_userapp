import 'package:flutter/material.dart';

class AddResidentScreen extends StatelessWidget {
  const AddResidentScreen({super.key});

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
            title: const Text('Add New Resident / Tenant'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          body: ListView(
            controller: controller,
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTextField(label: 'Resident Name', hint: 'Full Name'),
              _buildDropdownField(label: 'Residency Status', items: ['Owner', 'Tenant']),
              Row(
                children: [
                  Expanded(child: _buildTextField(label: 'Building / Wing', hint: 'e.g. Tower A')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(label: 'Flat Number', hint: 'e.g. 1204')),
                ],
              ),
              _buildTextField(label: 'Phone Number', hint: '+91 XXXXX XXXXX'),
              _buildTextField(label: 'Email Address', hint: 'email@example.com'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow[700], minimumSize: const Size.fromHeight(50)),
                child: const Text('Register Resident', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

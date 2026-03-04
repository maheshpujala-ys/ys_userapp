import 'package:flutter/material.dart';

class CreateVisitorPassScreen extends StatelessWidget {
  const CreateVisitorPassScreen({Key? key}) : super(key: key);

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
            title: const Text('Create Visitor Pass'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          body: ListView(
            controller: controller,
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTextField(label: 'Visitor Name', hint: 'Full Name'),
              _buildTextField(label: 'Phone Number', hint: '+91 XXXXX XXXXX'),
              _buildDropdownField(label: 'Purpose of Visit', items: ['Personal', 'Delivery', 'Maintenance', 'Guest']),
              _buildTextField(label: 'Visiting Unit / Flat', hint: 'e.g. Tower A - 1204'),
              _buildDropdownField(label: 'Validity Duration', items: ['4 Hours', '8 Hours', '24 Hours', '1 Week']),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Visitor Pass generated successfully!')),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Generate Pass', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[400],
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
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
            decoration: InputDecoration(
              hintText: hint, 
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
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
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }
}

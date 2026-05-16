import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/residents/domain/tenant_models.dart';
import 'package:yellowspotuser/features/admin/vehicles/application/registration_providers.dart';
import 'package:yellowspotuser/features/admin/vehicles/domain/registration_models.dart';

/// Creates a short-lived vehicle registration to serve as a visitor pass.
/// Maps to POST /api/v1/registrations with a tight start/end window.
class CreateVisitorPassScreen extends ConsumerStatefulWidget {
  const CreateVisitorPassScreen({super.key});

  @override
  ConsumerState<CreateVisitorPassScreen> createState() =>
      _CreateVisitorPassScreenState();
}

class _CreateVisitorPassScreenState
    extends ConsumerState<CreateVisitorPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _cardNumberController = TextEditingController();

  int? _hostTenantId;
  int? _vehicleTypeId;
  String _cardType = 'RFID';
  Duration _validity = const Duration(hours: 4);

  static const _validityChoices = <_ValidityOption>[
    _ValidityOption('4 Hours', Duration(hours: 4)),
    _ValidityOption('8 Hours', Duration(hours: 8)),
    _ValidityOption('24 Hours', Duration(hours: 24)),
    _ValidityOption('1 Week', Duration(days: 7)),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleNumberController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_hostTenantId == null || _vehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick the host and vehicle type')),
      );
      return;
    }
    final now = DateTime.now();
    final end = now.add(_validity);
    final request = VehicleRegistrationCreateRequest(
      tenantId: _hostTenantId!,
      vehicleNumber: _vehicleNumberController.text.trim(),
      vehicleTypeId: _vehicleTypeId!,
      ownerName: _nameController.text.trim(),
      ownerMobile: _phoneController.text.trim(),
      cardNumber: _cardNumberController.text.trim(),
      cardType: _cardType,
      startDate: now.toIso8601String(),
      endDate: end.toIso8601String(),
    );

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final ok = await ref
        .read(RegistrationController.provider.notifier)
        .submit(request);
    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Visitor Pass generated successfully')),
      );
      navigator.pop();
    } else {
      final err = ref.read(RegistrationController.provider).error;
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      RegistrationController.provider.select((s) => s.isLoading),
    );
    final tenants = ref.watch(tenantsListProvider);
    final vehicleTypes = ref.watch(vehicleTypesProvider);

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
              IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(16.0),
              children: [
                _labeled(
                  'Visitor Name',
                  TextFormField(
                    controller: _nameController,
                    decoration: _decoration('Full Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name required'
                        : null,
                  ),
                ),
                _labeled(
                  'Phone Number',
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _decoration('+91 XXXXX XXXXX'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Phone required'
                        : null,
                  ),
                ),
                _labeled(
                  'Vehicle Number',
                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: _decoration('e.g. TS09ER1234'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vehicle number required'
                        : null,
                  ),
                ),
                _labeled(
                  'Vehicle Type',
                  vehicleTypes.when(
                    data: (rows) => DropdownButtonFormField<int>(
                      initialValue: _vehicleTypeId,
                      items: rows
                          .map((t) => DropdownMenuItem<int>(
                              value: t.vehicleTypeId, child: Text(t.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _vehicleTypeId = v),
                      decoration: _decoration('Select type'),
                      validator: (v) =>
                          v == null ? 'Vehicle type required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Could not load types: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
                _labeled(
                  'Visiting Resident (Host)',
                  tenants.when(
                    data: (rows) => DropdownButtonFormField<int>(
                      initialValue: _hostTenantId,
                      items: rows
                          .map((t) => DropdownMenuItem<int>(
                                value: t.tenantId,
                                child: Text(_tenantLabel(t)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _hostTenantId = v),
                      decoration: _decoration('Select host'),
                      validator: (v) =>
                          v == null ? 'Host required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Could not load residents: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
                _labeled(
                  'Card Number',
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: _decoration('Card / RFID number'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Card number required'
                        : null,
                  ),
                ),
                _labeled(
                  'Card Type',
                  DropdownButtonFormField<String>(
                    initialValue: _cardType,
                    items: const [
                      DropdownMenuItem(value: 'RFID', child: Text('RFID')),
                      DropdownMenuItem(value: 'NFC', child: Text('NFC')),
                    ],
                    onChanged: (v) => setState(() => _cardType = v ?? 'RFID'),
                    decoration: _decoration(''),
                  ),
                ),
                _labeled(
                  'Validity',
                  DropdownButtonFormField<Duration>(
                    initialValue: _validity,
                    items: _validityChoices
                        .map((o) => DropdownMenuItem(
                            value: o.duration, child: Text(o.label)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _validity = v ?? _validityChoices.first.duration),
                    decoration: _decoration(''),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: isLoading
                      ? const Text('Working…')
                      : const Text('Generate Pass',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _tenantLabel(TenantSummary t) {
    final unit = [t.tower, t.flat].where((s) => s != null && s.isNotEmpty).join('-');
    return unit.isEmpty ? t.name : '${t.name} ($unit)';
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      );

  Widget _labeled(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _ValidityOption {
  const _ValidityOption(this.label, this.duration);
  final String label;
  final Duration duration;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/residents/application/add_resident_controller.dart';
import 'package:yellowspotuser/features/admin/smart_cards/application/add_smart_card_controller.dart';
import 'package:yellowspotuser/features/admin/smart_cards/data/smart_cards_remote_data_source.dart';
import 'package:yellowspotuser/features/admin/vehicles/application/registration_providers.dart';

/// Bottom-sheet form for issuing or editing a smart card / tag.
/// When [existing] is non-null the form pre-fills and submits via
/// `PUT /api/v1/smart_cards/{id}`. Otherwise `POST /api/v1/smart_cards`.
class AddSmartCardScreen extends ConsumerStatefulWidget {
  const AddSmartCardScreen({super.key, this.existing});

  final SmartCardSummary? existing;

  @override
  ConsumerState<AddSmartCardScreen> createState() => _AddSmartCardScreenState();
}

class _AddSmartCardScreenState extends ConsumerState<AddSmartCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardNumberController;
  late final TextEditingController _serialNumberController;

  late String _cardType;
  late String _allocationStatus;
  int? _locationId;
  int? _vehicleTypeId;
  late bool _active;

  bool get _isEdit => widget.existing != null;

  static const _cardTypes = ['RFID', 'NFC'];

  /// Backend expects a single-character flag: `Y` = Allocated, `N` = Available.
  static const _allocationStatuses = <_AllocOption>[
    _AllocOption(value: 'N', label: 'Available'),
    _AllocOption(value: 'Y', label: 'Allocated'),
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _cardNumberController = TextEditingController(text: s?.cardNumber ?? '');
    _serialNumberController =
        TextEditingController(text: s?.serialNumber ?? '');
    final t = s?.cardType;
    _cardType = (t != null && _cardTypes.contains(t)) ? t : _cardTypes.first;
    final a = (s?.allocationStatus ?? '').toUpperCase();
    _allocationStatus = (a == 'Y' || a == 'N') ? a : 'N';
    _locationId = s?.locationId;
    _vehicleTypeId = s?.vehicleTypeId;
    _active = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_locationId == null || _vehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a location and vehicle type')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final request = SmartCardCreateRequest(
      locationId: _locationId!,
      cardNumber: _cardNumberController.text.trim(),
      serialNumber: _serialNumberController.text.trim(),
      cardType: _cardType,
      allocationStatus: _allocationStatus,
      vehicleTypeId: _vehicleTypeId!,
      activeInd: _active ? 'Y' : 'N',
    );

    final controller = ref.read(AddSmartCardController.provider.notifier);
    final ok = _isEdit
        ? await controller.update(widget.existing!.smartCardId, request)
        : await controller.submit(request);

    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        SnackBar(
            content:
                Text(_isEdit ? 'Smart card updated' : 'Smart card issued')),
      );
      navigator.pop();
    } else {
      final err = ref.read(AddSmartCardController.provider).error;
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      AddSmartCardController.provider.select((s) => s.isLoading),
    );
    final locations = ref.watch(parkingLocationsProvider);
    final vehicleTypes = ref.watch(vehicleTypesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Scaffold(
          appBar: AppBar(
            title:
                Text(_isEdit ? 'Edit Smart Card' : 'Add Smart Card / Tag'),
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
                  'Location',
                  locations.when(
                    data: (rows) => DropdownButtonFormField<int>(
                      initialValue: _locationId,
                      items: rows
                          .map((l) => DropdownMenuItem<int>(
                              value: l.locationId, child: Text(l.name)))
                          .toList(),
                      onChanged: (v) => setState(() => _locationId = v),
                      decoration: _decoration('Select location'),
                      validator: (v) =>
                          v == null ? 'Location required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Could not load locations: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
                _labeled(
                  'Card Number',
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: _decoration('e.g. SC-PH-1204'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Card number required'
                        : null,
                  ),
                ),
                _labeled(
                  'Serial Number',
                  TextFormField(
                    controller: _serialNumberController,
                    decoration: _decoration('Card serial'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Serial number required'
                        : null,
                  ),
                ),
                _labeled(
                  'Card Type',
                  DropdownButtonFormField<String>(
                    initialValue: _cardType,
                    items: _cardTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _cardType = v ?? _cardTypes.first),
                    decoration: _decoration(''),
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
                  'Allocation Status',
                  DropdownButtonFormField<String>(
                    initialValue: _allocationStatus,
                    items: _allocationStatuses
                        .map((o) => DropdownMenuItem(
                            value: o.value, child: Text(o.label)))
                        .toList(),
                    onChanged: (v) => setState(() =>
                        _allocationStatus = v ?? _allocationStatuses.first.value),
                    decoration: _decoration(''),
                  ),
                ),
                if (_isEdit)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_active
                        ? 'Card is usable'
                        : 'Card disabled'),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: Icon(_isEdit ? Icons.save_outlined : Icons.add),
                  label: isLoading
                      ? const Text('Working…')
                      : Text(_isEdit ? 'Save Changes' : 'Issue Smart Card',
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[400],
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

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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

class _AllocOption {
  const _AllocOption({required this.value, required this.label});
  final String value;
  final String label;
}

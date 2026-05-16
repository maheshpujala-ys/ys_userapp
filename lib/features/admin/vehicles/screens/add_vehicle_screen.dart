import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/residents/application/add_resident_controller.dart';
import 'package:yellowspotuser/features/admin/residents/domain/tenant_models.dart';
import 'package:yellowspotuser/features/admin/vehicles/application/add_vehicle_controller.dart';
import 'package:yellowspotuser/features/admin/vehicles/application/registration_providers.dart';
import 'package:yellowspotuser/features/admin/vehicles/data/vehicles_remote_data_source.dart';

/// Admin flow to register OR edit a vehicle.
/// When [existing] is non-null the form pre-fills and submits via
/// `PUT /api/v1/vehicle/{id}`. Otherwise `POST /api/v1/vehicle`.
class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key, this.existing});

  final VehicleRegistrationSummary? existing;

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _vehicleNumberController;
  late final TextEditingController _empIdController;
  late final TextEditingController _carTypeController;
  late final TextEditingController _fastagController;
  late final TextEditingController _zoneIdController;

  int? _tenantId;
  int? _vehicleTypeId;
  int? _locationId;
  late String _registrationType;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _active;

  bool get _isEdit => widget.existing != null;

  static const _registrationTypes = ['PERMANENT', 'TEMP', 'VISITOR'];

  @override
  void initState() {
    super.initState();
    final v = widget.existing;
    _vehicleNumberController =
        TextEditingController(text: v?.vehicleNumber ?? '');
    _empIdController = TextEditingController(text: v?.empId ?? '');
    _carTypeController = TextEditingController(text: v?.carType ?? '');
    _fastagController = TextEditingController(text: v?.fastagRfNumber ?? '');
    _zoneIdController =
        TextEditingController(text: v?.zoneId?.toString() ?? '');
    _tenantId = v?.tenantId;
    _vehicleTypeId = v?.vehicleTypeId;
    _locationId = v?.locationId;
    final rt = v?.registrationType;
    _registrationType = (rt != null && _registrationTypes.contains(rt))
        ? rt
        : _registrationTypes.first;
    _startDate = _tryParseDate(v?.startDate) ?? DateTime.now();
    _endDate = _tryParseDate(v?.endDate);
    _active = v?.isActive ?? true;
  }

  DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _empIdController.dispose();
    _carTypeController.dispose();
    _fastagController.dispose();
    _zoneIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_tenantId == null || _vehicleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a resident and vehicle type')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final zoneIdText = _zoneIdController.text.trim();
    final zoneId = zoneIdText.isEmpty ? null : int.tryParse(zoneIdText);

    final request = VehicleCreateRequest(
      tenantId: _tenantId!,
      vehicleTypeId: _vehicleTypeId!,
      vehicleNumber: _vehicleNumberController.text.trim(),
      registrationType: _registrationType,
      startDate: _formatDate(_startDate),
      empId: _emptyToNull(_empIdController.text),
      carType: _emptyToNull(_carTypeController.text),
      fastagRfNumber: _emptyToNull(_fastagController.text),
      endDate: _endDate == null ? null : _formatDate(_endDate!),
      locationId: _locationId,
      zoneId: zoneId,
      smartCardId: widget.existing?.smartCardId,
      activeInd: _active ? 'Y' : 'N',
    );

    final controller = ref.read(AddVehicleController.provider.notifier);
    final ok = _isEdit
        ? await controller.update(widget.existing!.registrationId, request)
        : await controller.submit(request);

    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        SnackBar(
            content: Text(_isEdit ? 'Vehicle updated' : 'Vehicle registered')),
      );
      navigator.pop();
    } else {
      final err = ref.read(AddVehicleController.provider).error;
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  String? _emptyToNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : (_endDate ?? _startDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      AddVehicleController.provider.select((s) => s.isLoading),
    );
    final tenants = ref.watch(tenantsListProvider);
    final vehicleTypes = ref.watch(vehicleTypesProvider);
    final locations = ref.watch(parkingLocationsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEdit ? 'Edit Vehicle' : 'Add Vehicle'),
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
                  'Resident (Tenant)',
                  tenants.when(
                    data: (rows) => DropdownButtonFormField<int>(
                      initialValue: _tenantId,
                      items: rows
                          .map((t) => DropdownMenuItem<int>(
                                value: t.tenantId,
                                child: Text(_tenantLabel(t)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _tenantId = v),
                      decoration: _decoration('Select resident'),
                      validator: (v) =>
                          v == null ? 'Resident required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Could not load residents: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
                _labeled(
                  'Vehicle Number',
                  TextFormField(
                    controller: _vehicleNumberController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _decoration('e.g. KA01AB1234'),
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
                  'Registration Type',
                  DropdownButtonFormField<String>(
                    initialValue: _registrationType,
                    items: _registrationTypes
                        .map((t) =>
                            DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(
                        () => _registrationType = v ?? _registrationTypes.first),
                    decoration: _decoration(''),
                  ),
                ),
                _labeled(
                  'Car Type',
                  TextFormField(
                    controller: _carTypeController,
                    decoration: _decoration('e.g. SUV / Sedan'),
                  ),
                ),
                _labeled(
                  'Employee ID',
                  TextFormField(
                    controller: _empIdController,
                    decoration: _decoration('Optional (e.g. EMP12345)'),
                  ),
                ),
                _labeled(
                  'FASTag RF Number',
                  TextFormField(
                    controller: _fastagController,
                    decoration: _decoration('Optional'),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _labeled(
                        'Start Date',
                        _DateField(
                          value: _formatDate(_startDate),
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _labeled(
                        'End Date',
                        _DateField(
                          value: _endDate == null
                              ? '—'
                              : _formatDate(_endDate!),
                          onTap: () => _pickDate(isStart: false),
                          onClear: _endDate == null
                              ? null
                              : () => setState(() => _endDate = null),
                        ),
                      ),
                    ),
                  ],
                ),
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
                      decoration: _decoration('Optional'),
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Could not load locations: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
                _labeled(
                  'Zone ID',
                  TextFormField(
                    controller: _zoneIdController,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Optional (numeric)'),
                  ),
                ),
                if (_isEdit)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_active
                        ? 'Vehicle can enter the premises'
                        : 'Access disabled'),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: Icon(_isEdit ? Icons.save_outlined : Icons.add),
                  label: isLoading
                      ? const Text('Working…')
                      : Text(_isEdit ? 'Save Changes' : 'Add Vehicle',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.black,
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
    final unit =
        [t.tower, t.flat].whereType<String>().where((s) => s.isNotEmpty).join('-');
    return unit.isEmpty ? t.name : '${t.name} ($unit)';
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

/// Read-only field that opens a date picker on tap.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: onClear == null
              ? const Icon(Icons.calendar_today_outlined)
              : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                ),
        ),
        child: Text(value),
      ),
    );
  }
}

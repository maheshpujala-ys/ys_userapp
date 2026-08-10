import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yellowspotuser/features/admin/residents/application/add_resident_controller.dart';
import 'package:yellowspotuser/features/admin/residents/domain/tenant_models.dart';

/// Bottom-sheet form for creating or editing a resident (tenant).
/// When [existing] is non-null the form pre-fills and submits via
/// `PUT /api/v1/tenants/{id}`. Otherwise `POST /api/v1/tenants`.
class AddResidentScreen extends ConsumerStatefulWidget {
  const AddResidentScreen({super.key, this.existing});

  final TenantSummary? existing;

  @override
  ConsumerState<AddResidentScreen> createState() => _AddResidentScreenState();
}

class _AddResidentScreenState extends ConsumerState<AddResidentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _towerController;
  late final TextEditingController _flatController;
  late final TextEditingController _floorController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  late final TextEditingController _altMobileController;
  late final TextEditingController _addressController;

  late String _type;
  late int? _locationId;
  late bool _active;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existing;
    _nameController = TextEditingController(text: t?.name ?? '');
    _towerController = TextEditingController(text: t?.tower ?? '');
    _flatController = TextEditingController(text: t?.flat ?? '');
    _floorController = TextEditingController(text: t?.floor ?? '');
    _mobileController = TextEditingController(text: t?.mobile ?? '');
    _emailController = TextEditingController(text: t?.email ?? '');
    _altMobileController = TextEditingController(text: t?.altMobile ?? '');
    _addressController = TextEditingController(text: t?.address ?? '');
    _type = _canonicalType(t?.type);
    _locationId = t?.locationId;
    _active = t?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _towerController.dispose();
    _flatController.dispose();
    _floorController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _altMobileController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_locationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a location first')),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final request = TenantCreateRequest(
      name: _nameController.text.trim(),
      locationId: _locationId!,
      type: _type,
      tower: _emptyToNull(_towerController.text),
      flat: _emptyToNull(_flatController.text),
      floor: _emptyToNull(_floorController.text),
      mobile: _emptyToNull(_mobileController.text),
      email: _emptyToNull(_emailController.text),
      altMobile: _emptyToNull(_altMobileController.text),
      address: _emptyToNull(_addressController.text),
      activeInd: _active ? 'Y' : 'N',
    );

    final controller = ref.read(AddResidentController.provider.notifier);
    final ok = _isEdit
        ? await controller.update(widget.existing!.tenantId, request)
        : await controller.submit(request);

    if (!mounted) return;
    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Resident updated' : 'Resident added')),
      );
      navigator.pop();
    } else {
      final err = ref.read(AddResidentController.provider).error;
      messenger.showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  String? _emptyToNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  /// Maps any-case backend value ('tenant', 'OWNER', etc.) to the canonical
  /// dropdown value. Unknown values fall back to 'Owner'.
  static String _canonicalType(String? raw) {
    const known = ['Owner', 'Tenant'];
    if (raw == null || raw.trim().isEmpty) return 'Owner';
    final lower = raw.trim().toLowerCase();
    for (final k in known) {
      if (k.toLowerCase() == lower) return k;
    }
    return 'Owner';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      AddResidentController.provider.select((s) => s.isLoading),
    );
    final locations = ref.watch(parkingLocationsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_isEdit ? 'Edit Resident' : 'Add New Resident'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(16.0),
              children: [
                _labeled(
                  'Resident Name',
                  TextFormField(
                    controller: _nameController,
                    decoration: _decoration('Full Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name required'
                        : null,
                  ),
                ),
                _labeled(
                  'Residency Status',
                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    items: const [
                      DropdownMenuItem(value: 'Owner', child: Text('Owner')),
                      DropdownMenuItem(value: 'Tenant', child: Text('Tenant')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'Owner'),
                    decoration: _decoration(''),
                  ),
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
                      decoration: _decoration('Select location'),
                      validator: (v) =>
                          v == null ? 'Location required' : null,
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Could not load locations: $e',
                        style: const TextStyle(color: Colors.red)),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _labeled(
                        'Building / Wing',
                        TextFormField(
                          controller: _towerController,
                          decoration: _decoration('e.g. Tower A'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _labeled(
                        'Flat Number',
                        TextFormField(
                          controller: _flatController,
                          decoration: _decoration('e.g. 1204'),
                        ),
                      ),
                    ),
                  ],
                ),
                _labeled(
                  'Floor',
                  TextFormField(
                    controller: _floorController,
                    decoration: _decoration('e.g. 12'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                _labeled(
                  'Phone Number',
                  TextFormField(
                    controller: _mobileController,
                    decoration: _decoration('+91 XXXXX XXXXX'),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                _labeled(
                  'Alternate Phone',
                  TextFormField(
                    controller: _altMobileController,
                    decoration: _decoration('Optional'),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                _labeled(
                  'Email Address',
                  TextFormField(
                    controller: _emailController,
                    decoration: _decoration('email@example.com'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                _labeled(
                  'Address',
                  TextFormField(
                    controller: _addressController,
                    decoration: _decoration('Optional'),
                    maxLines: 2,
                  ),
                ),
                if (_isEdit)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_active
                        ? 'Resident can access the premises'
                        : 'Access disabled'),
                    value: _active,
                    onChanged: (v) => setState(() => _active = v),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          _isEdit ? 'Save Changes' : 'Register Resident',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
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
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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

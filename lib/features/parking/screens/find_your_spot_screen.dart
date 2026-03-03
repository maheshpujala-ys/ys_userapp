import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:yellowspotuser/core/providers/app_providers.dart';
import 'package:yellowspotuser/features/map/application/map_controller.dart';
import 'package:yellowspotuser/features/parking/application/parking_controller.dart';
import 'package:yellowspotuser/features/parking/screens/book_spot_screen.dart';

class FindYourSpotScreen extends ConsumerWidget {
  const FindYourSpotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(mapControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(17.3850, 78.4867), // Hyderabad
              zoom: 12,
            ),
            markers: mapState.asData?.value ?? {},
            onMapCreated: (GoogleMapController controller) {
              controller.setMapStyle('''
                [
                  {
                    "featureType": "poi",
                    "stylers": [
                      { "visibility": "off" }
                    ]
                  }
                ]
              ''');
            },
          ),
          _buildHeader(ref),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: _buildDraggableSheetContent(context, ref, scrollController),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined),
            const SizedBox(width: 8),
            const Text('Hyderabad', style: TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.arrow_drop_down),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search parking...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.notifications_none_outlined, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.yellow,
              child: Text('Y', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableSheetContent(BuildContext context, WidgetRef ref, ScrollController scrollController) {
    final parkingState = ref.watch(ParkingController.filteredProvider);

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nearby Parking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            parkingState.when(
              data: (parkingList) {
                if (parkingList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('No parking lots found matching your search.')),
                  );
                }
                return _buildParkingList(context, parkingList);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(child: Text(error.toString())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingList(BuildContext context, List<Map<String, dynamic>> parkingList) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: parkingList.length,
        itemBuilder: (context, index) {
          final parking = parkingList[index];
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ParkingListItem(
              mallName: parking['mallName'],
              distance: parking['distance'],
              availability: parking['availability'],
              address: parking['address'],
              price: parking['price'],
            ),
          );
        },
      ),
    );
  }
}

class ParkingListItem extends StatelessWidget {
  final String mallName;
  final String distance;
  final String availability;
  final String address;
  final String price;

  const ParkingListItem({
    super.key,
    required this.mallName,
    required this.distance,
    required this.availability,
    required this.address,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(mallName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.green.withAlpha(51),
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(availability, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
            Row(
              children: [
                Text(distance, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                const Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                const Text('Open', style: TextStyle(fontSize: 12)),
              ],
            ),
            Text(address, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
            Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: const [
                _ServiceChip(label: 'EV', icon: Icons.ev_station),
                _ServiceChip(label: 'CCTV', icon: Icons.videocam),
                _ServiceChip(label: 'Covered'),
                _ServiceChip(label: 'Valet'),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {}, 
                      child: const Text('Details', style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => const BookSpotScreen(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(80, 36),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Book Now', style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _ServiceChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.grey[700]),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

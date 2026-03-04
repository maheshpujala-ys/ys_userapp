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
          
          // Floating Notification Icon
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
                onPressed: () {
                  // Handle notification tap
                },
              ),
            ),
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.45,
            snap: true,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildDraggableSheetContent(context, ref),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableSheetContent(BuildContext context, WidgetRef ref) {
    final parkingState = ref.watch(ParkingController.filteredProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Handle
        Center(
          child: Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text(
            'Nearby Parking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 240, // Height for the horizontal list
          child: parkingState.when(
            data: (parkingList) {
              if (parkingList.isEmpty) {
                return const Center(child: Text('No parking lots found.'));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: parkingList.length,
                itemBuilder: (context, index) {
                  final parking = parkingList[index];
                  return SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: ParkingListItem(
                      mallName: parking['mallName'],
                      distance: parking['distance'],
                      availability: parking['availability'],
                      address: parking['address'],
                      price: parking['price'],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text(error.toString())),
          ),
        ),
        const SizedBox(height: 20),
      ],
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(mallName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(availability, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(distance, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(width: 8),
                    Icon(Icons.circle, size: 4, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    const Text('Open Now', style: TextStyle(fontSize: 12, color: Colors.blue)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: const [
                _CompactChip(label: 'EV', icon: Icons.ev_station),
                _CompactChip(label: 'CCTV'),
                _CompactChip(label: 'Valet'),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _CompactChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.grey[600]),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }
}

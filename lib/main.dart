import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const HappyHoursApp());
}

class HappyHoursApp extends StatelessWidget {
  const HappyHoursApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy Hours',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.yellow[50],
      ),
      home: const HappyHourListPage(),
    );
  }
}

class HappyHour {
  /*final int id;
  final String venueName;
  final String address;
  final String times;
  final String specials;
  final double latitude;
  final double longitude;*/

  final String venueName;
  final String address;
  final String times;
  final String specials;
  final double latitude;
  final double longitude;

  HappyHour({
    //required this.id,
    required this.venueName,
    required this.address,
    required this.times,
    required this.specials,
    required this.latitude,
    required this.longitude,
  });

  /*factory HappyHour.fromJson(Map<String, dynamic> json) {
    return HappyHour(
      id: json['id'],
      venueName: json['venueName'],
      address: json['address'],
      times: json['times'],
      specials: json['specials'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }
}*/

factory HappyHour.fromJson(Map<String, dynamic> json) {
    return HappyHour(
      venueName: json['venueName'] ?? '',
      address: json['address'] ?? '',
      times: json['times'] ?? '',
      specials: json['specials'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class HappyHourListPage extends StatefulWidget {
  const HappyHourListPage({super.key});

  @override
  State<HappyHourListPage> createState() => _HappyHourListPageState();
}

class _HappyHourListPageState extends State<HappyHourListPage> {
  List<HappyHour> happyHours = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchHappyHours();
  }

  Future<void> fetchHappyHours() async {
    try {
      final response = await http.get(Uri.parse('https://customercallsapp.com/prod/customercallsapp/happy_hours_api.php'));
      print('Raw response: ${response.body}'); // Debug raw response
      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        List<dynamic> happyHoursJson;
        if (data is List) {
          happyHoursJson = data;
        } else if (data is Map && data.containsKey('data')) {
          happyHoursJson = data['data'];
        } else {
          throw Exception('Unexpected JSON format: expected a list or object with "data" field');
        }
        setState(() {
          happyHours = happyHoursJson.map((json) => HappyHour.fromJson(json)).toList();
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch happy hours: Status ${response.statusCode}, body: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching happy hours: $e';
      });
      print('Error fetching happy hours: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Happy Hours'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddHappyHourPage()),
              ).then((_) => fetchHappyHours());
            },
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MapPage(happyHours: happyHours),
                ),
              );
            },
          ),
        ],
      ),
      body: errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchHappyHours,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : happyHours.isEmpty
              ? const Center(child: Text('No happy hours found. Add one!', style: TextStyle(fontSize: 18)))
              : ListView.builder(
                  itemCount: happyHours.length,
                  itemBuilder: (context, index) {
                    final happyHour = happyHours[index];
                    return ListTile(
                      title: Text(happyHour.venueName),
                      subtitle: Text('${happyHour.times} - ${happyHour.specials}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HappyHourDetailsPage(happyHour: happyHour),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class HappyHourDetailsPage extends StatelessWidget {
  final HappyHour happyHour;

  const HappyHourDetailsPage({super.key, required this.happyHour});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(happyHour.venueName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${happyHour.address}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Times: ${happyHour.times}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Specials: ${happyHour.specials}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(happyHour.latitude, happyHour.longitude),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(happyHour.latitude, happyHour.longitude),
                        child: const Icon(Icons.location_pin, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddHappyHourPage extends StatefulWidget {
  const AddHappyHourPage({super.key});

  @override
  State<AddHappyHourPage> createState() => _AddHappyHourPageState();
}

class _AddHappyHourPageState extends State<AddHappyHourPage> {
  final _formKey = GlobalKey<FormState>();
  final venueNameController = TextEditingController();
  final addressController = TextEditingController();
  final timesController = TextEditingController();
  final specialsController = TextEditingController();

  Future<Map<String, double>> geocodeAddress(String address) async {
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$address'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return {
            'latitude': double.parse(data[0]['lat']),
            'longitude': double.parse(data[0]['lon']),
          };
        }
      }
      return {'latitude': 0.0, 'longitude': 0.0};
    } catch (e) {
      print('Error geocoding address: $e');
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  Future<void> submitHappyHour() async {
    if (_formKey.currentState!.validate()) {
      final coords = await geocodeAddress(addressController.text);
      final happyHour = {
        'venueName': venueNameController.text,
        'address': addressController.text,
        'times': timesController.text,
        'specials': specialsController.text,
        'latitude': coords['latitude'],
        'longitude': coords['longitude'],
      };
      try {
        final response = await http.post(
          Uri.parse('https://customercallsapp.com/prod/customercallsapp/happy_hours_api.php'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(happyHour),
        );
        print('POST response: ${response.statusCode}, body: ${response.body}');
        if (response.statusCode == 201) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit: ${response.statusCode}, ${response.body}')),
          );
        }
      } catch (e) {
        print('Error submitting happy hour: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Happy Hour')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: venueNameController,
                decoration: const InputDecoration(labelText: 'Venue Name'),
                validator: (value) => value!.isEmpty ? 'Enter a venue name' : null,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Enter an address' : null,
              ),
              TextFormField(
                controller: timesController,
                decoration: const InputDecoration(labelText: 'Happy Hour Times'),
                validator: (value) => value!.isEmpty ? 'Enter times' : null,
              ),
              TextFormField(
                controller: specialsController,
                decoration: const InputDecoration(labelText: 'Specials'),
                validator: (value) => value!.isEmpty ? 'Enter specials' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitHappyHour,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapPage extends StatelessWidget {
  final List<HappyHour> happyHours;

  const MapPage({super.key, required this.happyHours});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Happy Hours Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(37.7749, -122.4194), // Default: San Francisco
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: happyHours
                .map((hh) => Marker(
                      point: LatLng(hh.latitude, hh.longitude),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HappyHourDetailsPage(happyHour: hh),
                            ),
                          );
                        },
                        child: const Icon(Icons.location_pin, color: Colors.red),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
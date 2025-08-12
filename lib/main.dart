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
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HappyHourListPage(),
    );
  }
}

class HappyHour {
  final String happyHourId;
  final String name;
  final String address;
  final String openHours;
  final String happyHourStart;
  final String happyHourEnd;
  final String telephone;
  final String imageLink;
  final double latitude;
  final double longitude;

  HappyHour({
    required this.happyHourId,
    required this.name,
    required this.address,
    required this.openHours,
    required this.happyHourStart,
    required this.happyHourEnd,
    required this.telephone,
    required this.imageLink,
    required this.latitude,
    required this.longitude,
  });

  factory HappyHour.fromJson(Map<String, dynamic> json) {
    const String baseUrl =
        'https://customercallsapp.com/prod/customercallsapp/';

    String image = json['image'] ?? '';
    String logo = json['logo'] ?? '';
    String selectedImageLink = '';

    if (image.isNotEmpty) {
      selectedImageLink =
          image.startsWith('http') ? image : baseUrl + image;
    } else if (logo.isNotEmpty) {
      selectedImageLink =
          logo.startsWith('http') ? logo : baseUrl + logo;
    } else {
      selectedImageLink = '';
    }

    return HappyHour(
      happyHourId: json['happy_hour_id'] ?? '',
      name: json['Name'] ?? '',
      address: json['Address'] ?? '',
      openHours: json['Open_hours'] ?? '',
      happyHourStart: json['Happy_hour_start'] ?? '',
      happyHourEnd: json['Happy_hour_end'] ?? '',
      telephone: json['Telephone'] ?? '',
      imageLink: json['image_link'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
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

  // NEW: City dropdown
  String? selectedCity;
  final List<String> cities = [
    'All',

    // Thailand
    'Bangkok',
    'Chiang Mai',
    'Phuket',
    'Pattaya',

    // USA
    'New York',
    'Los Angeles',
    'Chicago',
    'San Francisco',
    'Miami',

    // Europe
    'London',
    'Paris',
    'Berlin',
    'Rome',
    'Madrid',
    'Amsterdam',

    // Middle East
    'Dubai',
    'Abu Dhabi',
    'Doha',
    'Riyadh',
    'Jeddah',

    // India
    'Mumbai',
    'Delhi',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Kolkata',

    // Japan
    'Tokyo',
    'Osaka',
    'Kyoto',
    'Yokohama',
    'Sapporo',

    // Australia
    'Sydney',
    'Melbourne',
    'Brisbane',
    'Perth',
    'Adelaide',

    // New Zealand
    'Auckland',
    'Wellington',
    'Christchurch',
    'Queenstown'
  ];


  @override
  void initState() {
    super.initState();
    fetchHappyHours();
  }

  Future<void> fetchHappyHours() async {
    const int timeoutSeconds = 30;
    const int maxRetries = 2;

    // Build URL with optional city parameter
    String baseUrl =
        'https://customercallsapp.com/prod/customercallsapp/happy_hours_global_api.php';
    if (selectedCity != null &&
        selectedCity!.isNotEmpty &&
        selectedCity != 'All') {
      baseUrl += '?city=${Uri.encodeComponent(selectedCity!)}';
    }

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(baseUrl))
            .timeout(Duration(seconds: timeoutSeconds));

        if (response.statusCode == 200) {
          final List<dynamic> happyHoursJson = jsonDecode(response.body);
          List<HappyHour> tempHappyHours = happyHoursJson
              .map((json) => HappyHour.fromJson(json))
              .toList();

          setState(() {
            happyHours = tempHappyHours;
            errorMessage = null;
          });
          return;
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt == maxRetries) {
          setState(() {
            errorMessage = 'Error fetching data: $e';
          });
        } else {
          debugPrint("Attempt $attempt failed, retrying...");
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
  }

 /* @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Happy Hours', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.black),
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
      body: Column(
        children: [
          // NEW: Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCity ?? 'All',
              isExpanded: true,
              items: cities.map((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                });
                fetchHappyHours();
              },
            ),
          ),
          Expanded(
            child: errorMessage != null
                ? Center(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)))
                : happyHours.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: happyHours.length,
                        itemBuilder: (context, index) {
                          return HappyHourCard(
                              happyHour: happyHours[index], index: index);
                        },
                      ),
          ),
        ],
      ),
    );
  } */

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Happy Hours', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.black),
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
      body: Column(
        children: [
          // NEW: Styled Dropdown
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCity ?? 'All',
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Row(
                        children: [
                          const Icon(Icons.location_city, color: Colors.black54, size: 18),
                          const SizedBox(width: 8),
                          Text(city),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value;
                    });
                    fetchHappyHours();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: errorMessage != null
                ? Center(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)))
                : happyHours.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: happyHours.length,
                        itemBuilder: (context, index) {
                          return HappyHourCard(
                              happyHour: happyHours[index], index: index);
                        },
                      ),
          ),
        ],
      ),
    );
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Happy Hours', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.black),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return cities; // show all if empty
                }
                return cities.where((city) => city.toLowerCase()
                    .contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (String selection) {
                setState(() {
                  selectedCity = selection;
                });
                fetchHappyHours();
              },
              fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                controller.text = selectedCity ?? 'All';
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onEditingComplete: onEditingComplete,
                  decoration: InputDecoration(
                    labelText: 'Select City',
                    prefixIcon: const Icon(Icons.location_city),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: errorMessage != null
                ? Center(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)))
                : happyHours.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: happyHours.length,
                        itemBuilder: (context, index) {
                          return HappyHourCard(
                              happyHour: happyHours[index], index: index);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class HappyHourCard extends StatelessWidget {
  final HappyHour happyHour;
  final int index;

  const HappyHourCard({super.key, required this.happyHour, required this.index});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;
    final imageToShow = happyHour.imageLink.isNotEmpty
        ? happyHour.imageLink
        : 'https://picsum.photos/300/150?random=$index';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HappyHourDetailsPage(happyHour: happyHour),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  Image.network(
                    imageToShow,
                    width: double.infinity,
                    height: isSmallScreen ? 180 : 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: isSmallScreen ? 180 : 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  Container(
                    height: isSmallScreen ? 180 : 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Text(
                      happyHour.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.8),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          happyHour.address,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 13 : 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.blueAccent, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${happyHour.happyHourStart} - ${happyHour.happyHourEnd}',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 15,
                          color: Colors.black87,
                        ),
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

class HappyHourDetailsPage extends StatelessWidget {
  final HappyHour happyHour;

  const HappyHourDetailsPage({super.key, required this.happyHour});

  @override
  Widget build(BuildContext context) {
    final imageToShow = happyHour.imageLink.isNotEmpty
        ? happyHour.imageLink
        : 'https://picsum.photos/300/150?random=details';

    return Scaffold(
      appBar: AppBar(
        title:
            Text(happyHour.name, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageToShow,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image,
                      size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Address: ${happyHour.address}',
                style: const TextStyle(fontSize: 16)),
            Text('Open: ${happyHour.openHours}',
                style: const TextStyle(fontSize: 16)),
            Text(
                'Happy Hours: ${happyHour.happyHourStart} - ${happyHour.happyHourEnd}',
                style: const TextStyle(fontSize: 16)),
            Text('Phone: ${happyHour.telephone}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter:
                      LatLng(happyHour.latitude, happyHour.longitude),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                            happyHour.latitude, happyHour.longitude),
                        child: const Icon(Icons.location_pin,
                            color: Colors.red),
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

class MapPage extends StatelessWidget {
  final List<HappyHour> happyHours;

  const MapPage({super.key, required this.happyHours});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Map View', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(13.7563, 100.5018),
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: happyHours
                .where((hh) => hh.latitude != 0 && hh.longitude != 0)
                .map((hh) => Marker(
                      point: LatLng(hh.latitude, hh.longitude),
                      child: const Icon(Icons.location_pin,
                          color: Colors.red),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

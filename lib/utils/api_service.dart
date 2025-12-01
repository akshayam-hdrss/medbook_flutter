// import 'dart:convert'; // For JSON decoding
// import 'package:http/http.dart' as http; // For making HTTP requests

// // Fetch hospital categories
// Future<List<Map<String, String>>> fetchHospitalCategories() async {
//   const String url = 'https://medbook-backend-1.onrender.com/api/hospitalType';

//   try {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> resultData = data['resultData'];

//       return resultData.map((hospitalType) {
//         return {
//           'id': hospitalType['id'].toString(),
//           'category': hospitalType['name']?.toString() ?? '',
//           'icon': hospitalType['imageUrl']?.toString() ?? '',
//         };
//       }).toList();
//     } else {
//       throw Exception('Failed to load hospital categories');
//     }
//   } catch (e) {
//     print('Error fetching hospital categories: $e');
//     return [];
//   }
// }

// // Fetch hospitals based on hospitalTypeId
// Future<List<Map<String, String>>> fetchHospitalsByType(
//   String hospitalTypeId,
// ) async {
//   final String url =
//       'https://medbook-backend-1.onrender.com/api/hospital/$hospitalTypeId';

//   try {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> resultData = data['resultData'];

//       return resultData.map((hospital) {
//         return {
//           'id': hospital['id'].toString(),
//           'name': hospital['name'].toString(),
//           'area': hospital['area']?.toString() ?? '',
//           'phone': hospital['phone']?.toString() ?? '',
//           'mapLink': hospital['mapLink']?.toString() ?? '',
//           'imageUrl': hospital['imageUrl']?.toString() ?? '',
//           'rating': hospital['rating']?.toString() ?? '',
//         };
//       }).toList();
//     } else {
//       throw Exception('Failed to load hospitals');
//     }
//   } catch (e) {
//     print('Error fetching hospitals: $e');
//     return [];
//   }
// }

// // Fetch doctors based on hospitalId
// // Fetch doctors based on hospitalId
// Future<Map<String, dynamic>> fetchDoctorsByHospital(String hospitalId) async {
//   final String url =
//       'https://medbook-backend-1.onrender.com/api/doctor?hospitalId=$hospitalId';

//   try {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       final List<dynamic> resultData = data['resultData'];
//       final List<dynamic> categoryData = data['category'] ?? [];

//       final List<Map<String, String>> doctors = resultData.map((doctor) {
//         return {
//           'doctorId': doctor['id'].toString(),
//           'doctorName': doctor['doctorName']?.toString() ?? '',
//           'imageUrl': doctor['imageUrl']?.toString() ?? '',
//           'businessName': doctor['businessName']?.toString() ?? '',
//           'location': doctor['location']?.toString() ?? '',
//           'phone': doctor['phone']?.toString() ?? '',
//           'whatsapp': doctor['whatsapp']?.toString() ?? '',
//           'rating': doctor['rating']?.toString() ?? '',
//         };
//       }).toList();

//       final List<String> categories = categoryData
//           .map<String>((cat) => cat['text'].toString())
//           .toList();

//       return {'doctors': doctors, 'categories': categories};
//     } else {
//       throw Exception('Failed to load doctors');
//     }
//   } catch (e) {
//     print('Error fetching doctors: $e');
//     return {'doctors': [], 'categories': []};
//   }
// }
// // Fetch doctor details by doctorId
// // Function to fetch doctor details by ID

// Future<Map<String, dynamic>> fetchDoctorDetails(String doctorId) async {
//   final String url =
//       'https://medbook-backend-1.onrender.com/api/doctor/$doctorId';

//   try {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       return data['resultData']; // Return only the resultData
//     } else {
//       throw Exception('Failed to load doctor details');
//     }
//   } catch (e) {
//     print('Error fetching doctor details: $e');
//     return {}; // Return empty map if error occurs
//   }
// }

// // doctors_page api

// Future<List<Map<String, String>>> fetchDoctorTypes() async {
//   const String url = 'https://medbook-backend-1.onrender.com/api/doctorType';

//   try {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);

//       final List<dynamic> resultData = data['resultData'];

//       return resultData.map<Map<String, String>>((doctorType) {
//         return {
//           'id': doctorType['id'].toString(),
//           'category': doctorType['name']?.toString() ?? '',
//           'icon': doctorType['imageUrl']?.toString() ?? '',
//         };
//       }).toList();
//     } else {
//       throw Exception('Failed to load doctor types');
//     }
//   } catch (e) {
//     print('❌ Error fetching doctor types: $e');
//     return [];
//   }
// }

// // Function to fetch doctors by type

// Future<List<Map<String, dynamic>>> fetchDoctorsByType(String doctorTypeId) async {
//   final String url = 'https://medbook-backend-1.onrender.com/api/doctor?doctorTypeId=$doctorTypeId';

//   try {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> jsonData = json.decode(response.body);
//       final List<dynamic> doctorsList = jsonData['resultData'];

//       return doctorsList.map<Map<String, dynamic>>((item) {
//         return {
//           'id': item['_id'] ?? '',
//           'name': item['doctorName'] ?? 'N/A',
//           'speciality': item['speciality'] ?? 'General',
//           'image': item['profile'] ?? '',
//           'rating': item['rating'] ?? '4.5',
//         };
//       }).toList();
//     } else {
//       throw Exception('Failed to load doctors');
//     }
//   } catch (e) {
//     print('Error fetching doctors: $e');
//     return [];
//   }
// }

// // DoctorsPage3.dart API

// Future<Map<String, dynamic>> fetchDoctorDetails1(String doctorId) async {
//   final String url = 'https://medbook-backend-1.onrender.com/api/doctor/$doctorId';
//   print("Fetching from URL: $url");

//   try {
//     final response = await http.get(Uri.parse(url));
//     print("Status Code: ${response.statusCode}");

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       return data['resultData']; // Important: only return resultData
//     } else {
//       throw Exception('Failed to load doctor details');
//     }
//   } catch (e) {
//     print('Error fetching doctor details: $e');
//     return {}; // return empty map if there's an error
//   }
// }

// // Services

// // api_service.dart

// Future<List<dynamic>> fetchServiceDetails(String serviceId) async {
//   final url = 'https://medbook-backend-1.onrender.com/api/services/service-types/$serviceId';
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     final jsonBody = json.decode(response.body);
//     return jsonBody['resultData']; // Return the list
//   } else {
//     throw Exception('Failed to load service details');
//   }
// }

// // api_service.dart =>2

// Future<List<dynamic>> fetchServicesByType(String serviceTypeId) async {
//   const baseUrl = 'https://medbook-backend-1.onrender.com/api';
//   final response = await http.get(
//     Uri.parse('$baseUrl/services/services-by-type/$serviceTypeId'),
//   );

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     return data['resultData']; // ✅ This is the actual list
//   } else {
//     throw Exception('Failed to load services');
//   }
// }

// // api_service.dart =>3

// Future<Map<String, dynamic>> fetchServiceDetails1(String serviceId) async {
//   const String baseUrl = 'https://medbook-backend-1.onrender.com/api';
//   final response = await http.get(
//     Uri.parse('$baseUrl/services/service/$serviceId'),
//   );

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     print("Service detail: $data"); // ✅ Debug
//     return data['resultData'];
//   } else {
//     print("Failed with status: ${response.statusCode}");
//     throw Exception('Failed to load service details');
//   }
// }

// // api=> product-1

// class ApiService {
//   static const String baseUrl = "https://medbook-backend-1.onrender.com/api";

//   // ✅ 1. Fetch single product by availableProduct ID (used in ProductPage)
//   static Future<Map<String, dynamic>> fetchProductById(String id) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/products/productType/byAvailableProduct/$id"),
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception("Failed to load product data");
//     }
//   }

//   // ✅ 2. Fetch multiple products by productType ID (used in ProductPage2)
//   static Future<List<dynamic>> fetchProductsByProductType(String productTypeId) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/products/product/byProductType/$productTypeId"),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return data['resultData'] ?? [];
//     } else {
//       throw Exception("Failed to load products by product type");
//     }
//   }
//   // 3 product=>api
//    static Future<Map<String, dynamic>> fetchProductDetailsById(String productId) async {
//     final response = await http.get(
//       Uri.parse("$baseUrl/products/product/$productId"),
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception("Failed to load product details");
//     }
//   }

//   static Future fetchServiceByType(String serviceTypeId) async {}

//   Future<void> addProductReview(Map<String, Object?> map) async {}
// }

// class ApiServices {
//   static const String baseUrl = 'https://medbook-backend-1.onrender.com/api';

//   static Future<Map<String, dynamic>> get(String path) async {
//     final res = await http.get(Uri.parse('$baseUrl$path'));
//     return json.decode(res.body);
//   }

//   static Future<Map<String, dynamic>> post(
//       String path, Map<String, dynamic> body) async {
//     final res = await http.post(
//       Uri.parse('$baseUrl$path'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(body),
//     );
//     return json.decode(res.body);
//   }

//   static Future getDoctorById(String doctorId) async {}
// }

// // blog=>api

// class ApiServiceBlog {
//   static const String baseUrl = "https://medbook-backend-1.onrender.com/api";

//   static Future<List<dynamic>> fetchBlogs() async {
//     try {
//       final response = await http.get(Uri.parse("$baseUrl/blog"));

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);

//         if (data != null && data['resultData'] is Map) {
//           return [data['resultData']];
//         } else if (data['resultData'] is List) {
//           return data['resultData'];
//         } else {
//           return [];
//         }
//       } else {
//         throw Exception('Failed to load blogs');
//       }
//     } catch (e) {
//       throw Exception('API error: $e');
//     }
//   }
// }

import 'dart:convert'; // For JSON decoding
import 'package:http/http.dart' as http; // For making HTTP requests
import '../Services/secure_storage_service.dart'; // Add this import

// Fetch hospital categories
Future<List<Map<String, String>>> fetchHospitalCategories() async {
  const String url = 'https://medbook-backend-1.onrender.com/api/hospitalType';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> resultData = data['resultData'];

      // Sort by order_no (nulls last)
      resultData.sort((a, b) {
        final aOrder = a['order_no'];
        final bOrder = b['order_no'];

        if (aOrder == null && bOrder == null) return 0; // both null → equal
        if (aOrder == null) return 1; // a is null → goes last
        if (bOrder == null) return -1; // b is null → goes last

        return (aOrder as int).compareTo(bOrder as int); // ascending
      });

      // Now map into your desired format
      return resultData.map<Map<String, String>>((hospitalType) {
        return {
          'id': hospitalType['id'].toString(),
          'category': hospitalType['name']?.toString() ?? '',
          'icon': hospitalType['imageUrl']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load hospital categories');
    }
  } catch (e) {
    print('Error fetching hospital categories: $e');
    return [];
  }
}

// Fetch hospitals based on hospitalTypeId
Future<List<Map<String, String>>> fetchHospitalsByType(
  String hospitalTypeId,
) async {
  final storageService = SecureStorageService();
  String? area = await storageService.getSelectedArea();
  String? district = await storageService.getSelectedDistrict();

  // Build query parameters if area/district are present
  String query = '';
  if (area != null || district != null) {
    List<String> params = [];
    if (area != null) params.add('area=${Uri.encodeComponent(area)}');
    if (district != null) {
      params.add('district=${Uri.encodeComponent(district)}');
    }
    query = '?${params.join('&')}';
  }

  final String url =
      'https://medbook-backend-1.onrender.com/api/hospital/$hospitalTypeId$query';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> resultData = data['resultData'];

      // ✅ Sort by order_no (nulls go last)
      resultData.sort((a, b) {
        final aOrder = a['order_no'];
        final bOrder = b['order_no'];

        if (aOrder == null && bOrder == null) return 0; // both null → equal
        if (aOrder == null) return 1; // a is null → goes last
        if (bOrder == null) return -1; // b is null → goes last

        return (aOrder as int).compareTo(bOrder as int); // ascending
      });

      // Now map
      return resultData.map<Map<String, String>>((hospital) {
        return {
          'id': hospital['id'].toString(),
          'name': hospital['name'].toString(),
          'area': hospital['area']?.toString() ?? '',
          'phone': hospital['phone']?.toString() ?? '',
          'mapLink': hospital['mapLink']?.toString() ?? '',
          'imageUrl': hospital['imageUrl']?.toString() ?? '',
          'rating': hospital['rating']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load hospitals');
    }
  } catch (e) {
    print('Error fetching hospitals: $e');
    return [];
  }
}

// Fetch doctors based on hospitalId
Future<Map<String, dynamic>> fetchDoctorsByHospital(String hospitalId) async {
  final String url =
      'https://medbook-backend-1.onrender.com/api/doctor?hospitalId=$hospitalId';

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> resultData = data['resultData'];
      final List<dynamic> categoryData = data['category'] ?? [];

      // ✅ Sort by order_no (nulls go last)
      resultData.sort((a, b) {
        final aOrder = a['order_no'];
        final bOrder = b['order_no'];

        if (aOrder == null && bOrder == null) return 0; // both null → equal
        if (aOrder == null) return 1; // a is null → goes last
        if (bOrder == null) return -1; // b is null → goes last

        return (aOrder as int).compareTo(bOrder as int); // ascending
      });

      // Map doctors
      final List<Map<String, String>> doctors = resultData.map((doctor) {
        return {
          'doctorId': doctor['id'].toString(),
          'doctorName': doctor['doctorName']?.toString() ?? '',
          'imageUrl': doctor['imageUrl']?.toString() ?? '',
          'businessName': doctor['businessName']?.toString() ?? '',
          'location': doctor['location']?.toString() ?? '',
          'phone': doctor['phone']?.toString() ?? '',
          'whatsapp': doctor['whatsapp']?.toString() ?? '',
          'rating': doctor['rating']?.toString() ?? '',
          'degree': doctor['degree']?.toString() ?? '',
          'designation': doctor['designation']?.toString() ?? '',
          'category': doctor['category']?.toString() ?? '',
        };
      }).toList();

      // Map categories
      final List<String> categories = categoryData
          .map<String>((cat) => cat['text'].toString())
          .toList();

      return {'doctors': doctors, 'categories': categories};
    } else {
      throw Exception('Failed to load doctors');
    }
  } catch (e) {
    print('Error fetching doctors: $e');
    return {'doctors': [], 'categories': []};
  }
}

// Function to fetch doctor details by ID

Future<Map<String, dynamic>> fetchDoctorDetails(String doctorId) async {
  final String url =
      'https://medbook-backend-1.onrender.com/api/doctor/$doctorId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['resultData']; // Return only the resultData
    } else {
      throw Exception('Failed to load doctor details');
    }
  } catch (e) {
    print('Error fetching doctor details: $e');
    return {}; // Return empty map if error occurs
  }
}

// doctors_page api

Future<List<Map<String, String>>> fetchDoctorTypes() async {
  const String url = 'https://medbook-backend-1.onrender.com/api/doctorType';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> resultData = data['resultData'];

      // ✅ Sort by order_no (nulls last)
      resultData.sort((a, b) {
        final aOrder = a['order_no'];
        final bOrder = b['order_no'];

        if (aOrder == null && bOrder == null) return 0; // both null → equal
        if (aOrder == null) return 1; // a is null → goes last
        if (bOrder == null) return -1; // b is null → goes last

        return (aOrder as int).compareTo(bOrder as int); // ascending
      });

      // Map into your desired format
      return resultData.map<Map<String, String>>((doctorType) {
        return {
          'id': doctorType['id'].toString(),
          'category': doctorType['name']?.toString() ?? '',
          'icon': doctorType['imageUrl']?.toString() ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load doctor types');
    }
  } catch (e) {
    print('❌ Error fetching doctor types: $e');
    return [];
  }
}

// Function to fetch doctors by type

Future<List<Map<String, dynamic>>> fetchDoctorsByType(
  String doctorTypeId,
) async {
  final String url =
      'https://medbook-backend-1.onrender.com/api/doctor?doctorTypeId=$doctorTypeId';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final List<dynamic> doctorsList = jsonData['resultData'];

      return doctorsList.map<Map<String, dynamic>>((item) {
        return {
          'id': item['_id'] ?? '',
          'name': item['doctorName'] ?? 'N/A',
          'speciality': item['speciality'] ?? 'General',
          'image': item['profile'] ?? '',
          'rating': item['rating'] ?? '4.5',
        };
      }).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  } catch (e) {
    print('Error fetching doctors: $e');
    return [];
  }
}

// DoctorsPage3.dart API

Future<Map<String, dynamic>> fetchDoctorDetails1(String doctorId) async {
  final String url =
      'https://medbook-backend-1.onrender.com/api/doctor/$doctorId';
  print("Fetching from URL: $url");

  try {
    final response = await http.get(Uri.parse(url));
    print("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['resultData']; // Important: only return resultData
    } else {
      throw Exception('Failed to load doctor details');
    }
  } catch (e) {
    print('Error fetching doctor details: $e');
    return {}; // return empty map if there's an error
  }
}

// Services

// api_service.dart

// Future<List<dynamic>> fetchServiceDetails(String serviceId) async {
//   final url = 'https://medbook-backend-1.onrender.com/api/services/service-types/$serviceId';
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     final jsonBody = json.decode(response.body);
//     return jsonBody['resultData']; // Return the list
//   } else {
//     throw Exception('Failed to load service details');
//   }
// }

Future<List<dynamic>> fetchServiceDetails(String serviceId) async {
  final url =
      'https://medbook-backend-1.onrender.com/api/services/service-types/$serviceId';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);

    // Convert to List and sort by order_no (nulls go last)
    List<dynamic> resultData = List.from(jsonBody['resultData']);
    resultData.sort((a, b) {
      final aOrder = a['order_no'];
      final bOrder = b['order_no'];

      if (aOrder == null && bOrder == null) return 0; // both null → equal
      if (aOrder == null) return 1; // a is null → goes last
      if (bOrder == null) return -1; // b is null → goes last

      return (aOrder as int).compareTo(bOrder as int); // ascending
    });

    return resultData;
  } else {
    throw Exception('Failed to load service details');
  }
}

// api_service.dart =>2

Future<List<dynamic>> fetchServicesByType(String serviceTypeId) async {
  final storageService = SecureStorageService();
  String? area = await storageService.getSelectedArea();
  String? district = await storageService.getSelectedDistrict();

  const baseUrl = 'https://medbook-backend-1.onrender.com/api';

  // Build query string
  String query = '';
  if (area != null || district != null) {
    List<String> params = [];
    if (area != null) params.add('location=${Uri.encodeComponent(area)}');
    if (district != null) {
      params.add('district=${Uri.encodeComponent(district)}');
    }
    query = '?${params.join('&')}';
  }

  final url = '$baseUrl/services/services-by-type/$serviceTypeId$query';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // ✅ Sort by order_no (nulls last)
    List<dynamic> resultData = List.from(data['resultData']);
    resultData.sort((a, b) {
      final aOrder = a['order_no'];
      final bOrder = b['order_no'];

      if (aOrder == null && bOrder == null) return 0; // both null → equal
      if (aOrder == null) return 1; // a is null → goes last
      if (bOrder == null) return -1; // b is null → goes last

      return (aOrder as int).compareTo(bOrder as int); // ascending
    });

    return resultData;
  } else {
    throw Exception('Failed to load services');
  }
}

// api_service.dart =>3

Future<Map<String, dynamic>> fetchServiceDetails1(String serviceId) async {
  const String baseUrl = 'https://medbook-backend-1.onrender.com/api';
  final response = await http.get(
    Uri.parse('$baseUrl/services/service/$serviceId'),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print("Service detail: $data"); // ✅ Debug
    return data['resultData'];
  } else {
    print("Failed with status: ${response.statusCode}");
    throw Exception('Failed to load service details');
  }
}

// api=> product-1

class ApiService {
  static const String baseUrl = "https://medbook-backend-1.onrender.com/api";

  static Future<Map<String, dynamic>> getData(String endpoint) async {
    final response = await http.get(Uri.parse("$baseUrl$endpoint"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
        "Failed to load data from $endpoint. Status code: ${response.statusCode}",
      );
    }
  }

  // ✅ 1. Fetch single product by availableProduct ID (used in ProductPage)

  static Future<Map<String, dynamic>> fetchProductById(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/products/productType/byAvailableProduct/$id"),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);

      if (body.containsKey('resultData') && body['resultData'] is List) {
        final List<dynamic> resultData = body['resultData'];

        // ✅ Sort by order_no (null goes to the end)
        resultData.sort((a, b) {
          final orderA = a['order_no'];
          final orderB = b['order_no'];

          if (orderA == null && orderB == null) return 0;
          if (orderA == null) return 1; // null → after non-null
          if (orderB == null) return -1;

          return orderA.compareTo(orderB); // ascending order
        });

        body['resultData'] = resultData; // update sorted list
      }

      return body;
    } else {
      throw Exception("Failed to load product data");
    }
  }

  // ✅ 2. Fetch multiple products by productType ID (used in ProductPage2)
  static Future<List<dynamic>> fetchProductsByProductType(
    String productTypeId,
  ) async {
    final storageService = SecureStorageService();
    String? area = await storageService.getSelectedArea();
    String? district = await storageService.getSelectedDistrict();

    // Build query string
    String query = '';
    if (area != null || district != null) {
      List<String> params = [];
      if (area != null) params.add('location=${Uri.encodeComponent(area)}');
      if (district != null) {
        params.add('district=${Uri.encodeComponent(district)}');
      }
      query = '?${params.join('&')}';
    }

    final response = await http.get(
      Uri.parse("$baseUrl/products/product/byProductType/$productTypeId$query"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> products = data['resultData'] ?? [];

      // ✅ Sort by order_no (null goes to end)
      products.sort((a, b) {
        final orderA = a['order_no'];
        final orderB = b['order_no'];

        if (orderA == null && orderB == null) return 0;
        if (orderA == null) return 1; // null goes to end
        if (orderB == null) return -1;
        return orderA.compareTo(orderB); // ascending
      });

      return products;
    } else {
      throw Exception("Failed to load products by product type");
    }
  }

  // 3 product=>api
  static Future<Map<String, dynamic>> fetchProductDetailsById(
    String productId,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/products/product/$productId"),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // If the API response contains a list inside product details, sort it
      if (data is Map<String, dynamic> && data['resultData'] is List) {
        List<dynamic> resultList = data['resultData'];

        resultList.sort((a, b) {
          final orderA = a['order_no'];
          final orderB = b['order_no'];

          if (orderA == null && orderB == null) return 0;
          if (orderA == null) return 1; // null goes to end
          if (orderB == null) return -1;

          return orderA.compareTo(orderB);
        });

        data['resultData'] = resultList;
      }

      return data;
    } else {
      throw Exception("Failed to load product details");
    }
  }

  static Future fetchServiceByType(String serviceTypeId) async {}

  Future<void> addProductReview(Map<String, Object?> map) async {}
}

class ApiServices {
  static const String baseUrl = 'https://medbook-backend-1.onrender.com/api';

  static Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'));
    return json.decode(res.body);
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return json.decode(res.body);
  }

  static Future getDoctorById(String doctorId) async {}
}

// blog=>api

class ApiServiceBlog {
  static const String baseUrl = "https://medbook-backend-1.onrender.com/api";

  static Future<List<dynamic>> fetchBlogs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/blog"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['resultData'] is Map) {
          return [data['resultData']];
        } else if (data['resultData'] is List) {
          return data['resultData'];
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load blogs');
      }
    } catch (e) {
      throw Exception('API error: $e');
    }
  }
}

class ApiServiceADS {
  static const String _baseUrl = 'https://medbook-backend-1.onrender.com';

  Future<Map<String, dynamic>> getData(String endpoint) async {
    final Uri url = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('API Error: ${response.statusCode}');
        return {
          'result': 'Error',
          'message': 'Failed with status code ${response.statusCode}',
        };
      }
    } catch (e) {
      print('API Exception: $e');
      return {'result': 'Error', 'message': 'Exception: $e'};
    }
  }
}

// traditional

// class ApiServicetraditional {
//   static const String baseUrl = 'https://medbook-backend-1.onrender.com/api';

//   static Future<List<Map<String, String>>> fetchTraditionalTypes() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/traditionaltype'));

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         final List<dynamic> resultData = data['resultData'];

//         return resultData.map<Map<String, String>>((type) {
//           return {
//             'id': type['id']?.toString() ?? '',
//             'name': type['name']?.toString() ?? '',
//             'description': type['description']?.toString() ?? '',
//             'image': type['imageUrl']?.toString() ?? '',
//           };
//         }).toList();
//       } else {
//         throw Exception('Failed to load traditional types');
//       }
//     } catch (e) {
//       print('❌ Error fetching traditional types: $e');
//       return [];
//     }
//   }
//   static Future<List<dynamic>> fetchTraditionalByTypeId(String typeId) async {
//     final response = await http.get(Uri.parse('$baseUrl/traditional/$typeId'));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> body = jsonDecode(response.body);

//       // ✅ Extract the actual list
//       return body['resultData'] ?? [];
//     } else {
//       throw Exception('Failed to load traditional data');
//     }
//   }
// }

class ApiServicetraditional {
  static const String baseUrl = 'https://medbook-backend-1.onrender.com/api';

  static Future<List<Map<String, String>>> fetchTraditionalTypes() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/traditionaltype'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        final List<dynamic> resultData = data['resultData'];

        // ✅ Convert & include order_no for sorting
        List<Map<String, dynamic>> types = resultData.map((type) {
          return {
            'id': type['id']?.toString() ?? '',
            'name': type['name']?.toString() ?? '',
            'description': type['description']?.toString() ?? '',
            'image': type['imageUrl']?.toString() ?? '',
            'order_no': type['order_no'], // keep as dynamic (may be null)
          };
        }).toList();

        // ✅ Sort: null order_no → end, otherwise ascending
        types.sort((a, b) {
          final orderA = a['order_no'];
          final orderB = b['order_no'];

          if (orderA == null && orderB == null) return 0;
          if (orderA == null) return 1; // null → after non-null
          if (orderB == null) return -1;

          return orderA.compareTo(orderB); // ascending
        });

        // ✅ Convert back to List<Map<String, String>> (drop order_no if not needed)
        return types.map<Map<String, String>>((type) {
          return {
            'id': type['id'],
            'name': type['name'],
            'description': type['description'],
            'image': type['image'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load traditional types');
      }
    } catch (e) {
      print('❌ Error fetching traditional types: $e');
      return [];
    }
  }

  static Future<List<dynamic>> fetchTraditionalByTypeId(String typeId) async {
    final response = await http.get(Uri.parse('$baseUrl/traditional/$typeId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      List<dynamic> resultData = body['resultData'] ?? [];

      // ✅ Sort by order_no ascending, null values at the end
      resultData.sort((a, b) {
        final aOrder = a['order_no'];
        final bOrder = b['order_no'];

        if (aOrder == null && bOrder == null) return 0;
        if (aOrder == null) return 1; // a goes last
        if (bOrder == null) return -1; // b goes last

        return aOrder.compareTo(bOrder);
      });

      return resultData;
    } else {
      throw Exception('Failed to load traditional data');
    }
  }
}



// schedule

class Schedule {
  static const String baseUrl =
      "https://medbook-backend-1.onrender.com/api";

  /// 🔹 Get doctor schedules
  static Future<List<Map<String, dynamic>>> fetchDoctorSchedules(
      int doctorId) async {
    final url = Uri.parse("$baseUrl/bookings/doctor/31");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Make sure it’s a list
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else if (data['data'] is List) {
        // some APIs wrap result in { "data": [...] }
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        return [];
      }
    } else {
      throw Exception(
          "Failed to fetch schedules: ${response.statusCode}");
    }
  }
}
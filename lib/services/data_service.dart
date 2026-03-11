import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:avalokan/models/business_data.dart';

class DataService {
  Future<AppData> loadAppData() async {
    final jsonStr = await rootBundle.loadString('assets/sample_data.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return AppData.fromJson(map);
  }
}

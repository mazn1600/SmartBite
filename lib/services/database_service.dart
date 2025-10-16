import 'dart:async';
import '../models/user.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Mock database for now - replace with PostgreSQL later
  final List<Map<String, dynamic>> _mockUsers = [];
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    // Mock connection - always succeeds
    _isConnected = true;
    print('Connected to mock database');
  }

  Future<void> disconnect() async {
    _isConnected = false;
    print('Disconnected from mock database');
  }

  // User Authentication Methods
  Future<User?> authenticateUser(String email, String password) async {
    if (!_isConnected) await connect();
    if (!_isConnected) return null;

    try {
      // Mock authentication - find user by email
      final userData = _mockUsers.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
        orElse: () => {},
      );

      if (userData.isNotEmpty) {
        return User.fromJson({
          'id': userData['id'],
          'email': userData['email'],
          'name': userData['name'],
          'age': userData['age'],
          'height': userData['height'],
          'weight': userData['weight'],
          'gender': userData['gender'],
          'activityLevel': userData['activityLevel'],
          'goal': userData['goal'],
          'allergies': userData['allergies'] ?? [],
          'healthConditions': userData['healthConditions'] ?? [],
          'foodPreferences': userData['foodPreferences'] ?? [],
          'createdAt': DateTime.parse(userData['createdAt']),
          'updatedAt': DateTime.parse(userData['updatedAt']),
        });
      }
      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  Future<bool> registerUser(User user, String password) async {
    if (!_isConnected) await connect();
    if (!_isConnected) return false;

    try {
      // Check if email already exists
      if (_mockUsers.any((u) => u['email'] == user.email)) {
        return false;
      }

      // Add user to mock database
      _mockUsers.add({
        'id': user.id,
        'email': user.email,
        'password': password,
        'name': user.name,
        'age': user.age,
        'height': user.height,
        'weight': user.weight,
        'gender': user.gender,
        'activityLevel': user.activityLevel,
        'goal': user.goal,
        'allergies': user.allergies,
        'healthConditions': user.healthConditions,
        'foodPreferences': user.foodPreferences,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
      });

      print('User registered successfully in mock database');
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    if (!_isConnected) await connect();
    if (!_isConnected) return false;

    try {
      final index = _mockUsers.indexWhere((u) => u['id'] == user.id);
      if (index != -1) {
        _mockUsers[index] = {
          'id': user.id,
          'email': user.email,
          'password': _mockUsers[index]['password'], // Keep existing password
          'name': user.name,
          'age': user.age,
          'height': user.height,
          'weight': user.weight,
          'gender': user.gender,
          'activityLevel': user.activityLevel,
          'goal': user.goal,
          'allergies': user.allergies,
          'healthConditions': user.healthConditions,
          'foodPreferences': user.foodPreferences,
          'createdAt': _mockUsers[index]
              ['createdAt'], // Keep original creation date
          'updatedAt': user.updatedAt.toIso8601String(),
        };
        return true;
      }
      return false;
    } catch (e) {
      print('Update user error: $e');
      return false;
    }
  }

  Future<User?> getUserById(String userId) async {
    if (!_isConnected) await connect();
    if (!_isConnected) return null;

    try {
      final userData = _mockUsers.firstWhere(
        (user) => user['id'] == userId,
        orElse: () => {},
      );

      if (userData.isNotEmpty) {
        return User.fromJson({
          'id': userData['id'],
          'email': userData['email'],
          'name': userData['name'],
          'age': userData['age'],
          'height': userData['height'],
          'weight': userData['weight'],
          'gender': userData['gender'],
          'activityLevel': userData['activityLevel'],
          'goal': userData['goal'],
          'allergies': userData['allergies'] ?? [],
          'healthConditions': userData['healthConditions'] ?? [],
          'foodPreferences': userData['foodPreferences'] ?? [],
          'createdAt': DateTime.parse(userData['createdAt']),
          'updatedAt': DateTime.parse(userData['updatedAt']),
        });
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  // Database Schema Creation (mock)
  Future<void> createTables() async {
    if (!_isConnected) await connect();
    if (!_isConnected) return;

    try {
      print('Mock database tables created successfully');
    } catch (e) {
      print('Error creating tables: $e');
    }
  }

  // Health data validation
  Future<bool> validateHealthData({
    required int age,
    required double height,
    required double weight,
    required String gender,
  }) async {
    if (age < AppConstants.minAge || age > AppConstants.maxAge) return false;
    if (height < AppConstants.minHeight || height > AppConstants.maxHeight)
      return false;
    if (weight < AppConstants.minWeight || weight > AppConstants.maxWeight)
      return false;
    if (!AppConstants.genders.contains(gender.toLowerCase())) return false;
    return true;
  }

  // Check if email already exists
  Future<bool> emailExists(String email) async {
    if (!_isConnected) await connect();
    if (!_isConnected) return false;

    try {
      return _mockUsers.any((user) => user['email'] == email);
    } catch (e) {
      print('Email check error: $e');
      return false;
    }
  }

  // Get all users (for debugging)
  List<Map<String, dynamic>> getAllUsers() {
    return List.from(_mockUsers);
  }
}

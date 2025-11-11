import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/firestore_service.dart';

class AdminController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  
  RxList<UserModel> users = <UserModel>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }
  
  Future<void> loadUsers() async {
    isLoading.value = true;
    
    try {
      final fetchedUsers = await _firestoreService.getAllUsers();
      users.value = fetchedUsers;
    } catch (e) {
      print('Error loading users: $e');
      Get.snackbar(
        'Error',
        'Failed to load users: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> searchUsers(String query) async {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      loadUsers();
      return;
    }
    
    isLoading.value = true;
    
    try {
      final searchResults = await _firestoreService.searchUsers(query);
      users.value = searchResults;
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.deleteUser(userId);
      users.removeWhere((user) => user.uid == userId);
      
      Get.snackbar(
        'Success',
        'User deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete user: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final userIndex = users.indexWhere((user) => user.uid == userId);
      if (userIndex == -1) return;
      
      final updatedUser = users[userIndex].copyWith(
        role: newRole,
        updatedAt: DateTime.now(),
      );
      
      await _firestoreService.updateUser(updatedUser);
      users[userIndex] = updatedUser;
      users.refresh();
      
      
      Get.snackbar(
        'Success',
        'User role updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update role: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

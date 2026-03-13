import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CloudinaryService {
  // Cloudinary cloud name from dashboard
  static const String cloudName = 'dg3uu7mtg';
  
  // Cloudinary upload preset (unsigned)
  static const String uploadPreset = 'moodify_upload';
  
  /// Upload profile photo to Cloudinary
  /// Returns the secure URL if successful
  Future<String?> uploadProfilePhoto(File imageFile) async {
    try {
      // Validate credentials
      if (cloudName == 'YOUR_CLOUD_NAME' || uploadPreset == 'YOUR_UPLOAD_PRESET') {
        throw Exception(
          'Cloudinary not configured!\n'
          '1. Sign up at https://cloudinary.com\n'
          '2. Get your cloud name from Dashboard\n'
          '3. Create an unsigned upload preset in Settings > Upload > Upload presets\n'
          '4. Update lib/services/cloudinary_service.dart with your credentials',
        );
      }
      
      print('🌥️ Starting Cloudinary upload...');
      
      // Compress image first
      final compressedFile = await _compressImage(imageFile);
      final fileToUpload = compressedFile ?? imageFile;
      
      print('📦 File size: ${await fileToUpload.length()} bytes');
      
      // Read file as bytes
      final fileBytes = await fileToUpload.readAsBytes();
      
      // Create multipart request
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url);
      
      // Add upload preset
      request.fields['upload_preset'] = uploadPreset;
      
      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      
      print('☁️ Uploading to Cloudinary...');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final secureUrl = data['secure_url'] as String;
        
        print('✅ Upload successful!');
        print('🔗 URL: $secureUrl');
        print('🆔 Public ID: ${data['public_id']}');
        
        return secureUrl;
      } else {
        print('❌ Upload failed: ${response.body}');
        throw Exception('Failed to upload to Cloudinary: ${response.body}');
      }
    } catch (e) {
      print('❌ Error uploading to Cloudinary: $e');
      throw Exception('Cloudinary upload error: $e');
    }
  }
  
  /// Upload audio file to Cloudinary (for wellness music)
  /// Returns the secure URL if successful
  Future<String?> uploadAudioFile(File audioFile, {String? title}) async {
    try {
      // Validate credentials
      if (cloudName == 'YOUR_CLOUD_NAME' || uploadPreset == 'YOUR_UPLOAD_PRESET') {
        throw Exception('Cloudinary not configured!');
      }
      
      print('🎵 Starting Cloudinary audio upload...');
      
      // Read file as bytes
      final fileBytes = await audioFile.readAsBytes();
      
      print('📦 Audio file size: ${await audioFile.length()} bytes');
      
      // Create multipart request
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');
      final request = http.MultipartRequest('POST', url);
      
      // Add upload preset
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = 'wellness_audio';
      request.fields['resource_type'] = 'auto';
      
      // Add file
      final fileName = '${title?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'audio'}_${DateTime.now().millisecondsSinceEpoch}';
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: '$fileName.mp3',
        ),
      );
      
      print('☁️ Uploading audio to Cloudinary...');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final secureUrl = data['secure_url'] as String;
        
        print('✅ Audio upload successful!');
        print('🔗 URL: $secureUrl');
        print('🆔 Public ID: ${data['public_id']}');
        
        return secureUrl;
      } else {
        print('❌ Audio upload failed: ${response.body}');
        throw Exception('Failed to upload audio to Cloudinary: ${response.body}');
      }
    } catch (e) {
      print('❌ Error uploading audio to Cloudinary: $e');
      throw Exception('Cloudinary audio upload error: $e');
    }
  }
  
  /// Compress image before upload
  Future<File?> _compressImage(File imageFile) async {
    try {
      final targetPath = '${(await getTemporaryDirectory()).path}/cloudinary_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.path,
        targetPath,
        quality: 85,
        minWidth: 512,
        minHeight: 512,
        format: CompressFormat.jpeg,
      );
      
      if (result != null) {
        final fileSize = await result.length();
        print('📦 Compressed from ${await imageFile.length()} to $fileSize bytes');
        return File(result.path);
      }
      return null;
    } catch (e) {
      print('⚠️ Compression failed: $e');
      return null;
    }
  }
  
  /// Delete image from Cloudinary (requires admin API)
  /// This is optional - Cloudinary URLs are permanent by default
  Future<void> deleteImage(String publicId) async {
    print('⚠️ Image deletion requires Cloudinary admin API with signature');
    print('ℹ️ See: https://cloudinary.com/documentation/admin_api#delete_images');
    // Implementation requires server-side signing for security
  }
}

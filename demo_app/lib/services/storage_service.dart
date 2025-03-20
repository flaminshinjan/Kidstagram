import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Upload an image to Supabase storage and return the URL
  Future<String?> uploadImage(File imageFile, {String bucket = 'post_images'}) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final fileExt = path.extension(imageFile.path);
      final fileName = '${const Uuid().v4()}$fileExt';
      final filePath = 'public/$fileName'; // Simplified path without user ID for testing
      
      // Check if the file exists and is readable
      if (!await imageFile.exists()) {
        print('File does not exist: ${imageFile.path}');
        return null;
      }
      
      print('Uploading file: $filePath to bucket: $bucket');
      
      // Ensure bucket exists (this will return an error if it doesn't exist but won't throw)
      try {
        await _supabase.storage.getBucket(bucket);
        print('Bucket $bucket exists');
      } catch (e) {
        print('Bucket error, trying to create: $e');
        // Try to create bucket if it doesn't exist
        try {
          await _supabase.storage.createBucket(bucket);
          print('Bucket $bucket created successfully');
        } catch (bucketError) {
          print('Failed to create bucket: $bucketError');
          // Continue anyway as the bucket might actually exist despite the error
        }
      }
      
      try {
        // Upload the file with explicit content type
        final bytes = await imageFile.readAsBytes();
        final String mimeType = _getMimeType(fileExt);
        
        await _supabase
            .storage
            .from(bucket)
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(
                contentType: mimeType,
                upsert: true,
              ),
            );
        
        print('File uploaded successfully to $filePath');
        
        // Get the public URL
        final imageUrl = _supabase
            .storage
            .from(bucket)
            .getPublicUrl(filePath);
        
        print('Image URL: $imageUrl');
        return imageUrl;
      } catch (uploadError) {
        print('Failed at binary upload stage: $uploadError');
        return null;
      }
    } on StorageException catch (e) {
      print('Storage Exception uploading image: ${e.message}, ${e.statusCode}, ${e.error}');
      return null;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
  
  // Delete an image from storage
  Future<bool> deleteImage(String imageUrl, {String bucket = 'post_images'}) async {
    try {
      // Extract the path from the URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      
      // The path should be something like "storage/v1/object/public/bucket/public/filename"
      if (pathSegments.length < 4) {
        print('Invalid path segments length: ${pathSegments.length}');
        return false;
      }
      
      // Get the filename from the end of the path
      final filePath = pathSegments.last;
      print('Attempting to delete file: $filePath from bucket: $bucket');
      
      await _supabase
          .storage
          .from(bucket)
          .remove(['public/$filePath']);
      
      print('File deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
  
  // Helper method to determine MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.svg':
        return 'image/svg+xml';
      default:
        return 'application/octet-stream'; // Default binary
    }
  }
} 
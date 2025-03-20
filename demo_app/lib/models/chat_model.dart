import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async'; // Add this import for StreamController

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isRead;
  final String? senderAvatarUrl;
  final String? senderUsername;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isRead,
    this.senderAvatarUrl,
    this.senderUsername,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      senderAvatarUrl: json['sender_avatar_url'],
      senderUsername: json['sender_username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'sender_avatar_url': senderAvatarUrl,
      'sender_username': senderUsername,
    };
  }
}

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get conversations for current user
  Future<List<ChatConversation>> getConversations() async {
    final currentUserId = _supabase.auth.currentUser!.id;
    
    // Get the latest message from each unique conversation
    final response = await _supabase
      .from('chat_messages')
      .select('''
        id,
        content,
        created_at,
        is_read,
        sender:sender_id(id, avatar_url, username),
        receiver:receiver_id(id, avatar_url, username)
      ''')
      .or('sender_id.eq.$currentUserId,receiver_id.eq.$currentUserId')
      .order('created_at', ascending: false);
    
    // Process the response to get unique conversations
    final Map<String, ChatConversation> conversationsMap = {};
    
    for (final item in response) {
      final senderId = item['sender']['id'];
      final receiverId = item['receiver']['id'];
      
      // Determine if the current user is the sender or receiver
      final otherUserId = senderId == currentUserId ? receiverId : senderId;
      final otherUserData = senderId == currentUserId ? item['receiver'] : item['sender'];
      
      if (!conversationsMap.containsKey(otherUserId)) {
        conversationsMap[otherUserId] = ChatConversation(
          userId: otherUserId,
          username: otherUserData['username'] ?? 'User',
          avatarUrl: otherUserData['avatar_url'],
          lastMessage: item['content'],
          lastMessageTime: DateTime.parse(item['created_at']),
          unreadCount: item['is_read'] == false && senderId != currentUserId ? 1 : 0,
        );
      }
    }
    
    return conversationsMap.values.toList()
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }
  
  // Get messages between current user and another user
  Future<List<ChatMessage>> getMessages(String otherUserId) async {
    final currentUserId = _supabase.auth.currentUser!.id;
    
    final response = await _supabase
      .from('chat_messages')
      .select('''
        *,
        sender:profiles!sender_id(avatar_url, username)
      ''')
      .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId)')
      .order('created_at');
    
    return response.map<ChatMessage>((item) {
      final senderProfile = item['sender'];
      return ChatMessage(
        id: item['id'],
        senderId: item['sender_id'],
        receiverId: item['receiver_id'],
        content: item['content'],
        createdAt: DateTime.parse(item['created_at']),
        isRead: item['is_read'] ?? false,
        senderAvatarUrl: senderProfile?['avatar_url'],
        senderUsername: senderProfile?['username'],
      );
    }).toList();
  }
  
  // Send a message
  Future<ChatMessage> sendMessage(String receiverId, String content) async {
    final currentUserId = _supabase.auth.currentUser!.id;
    
    final response = await _supabase
      .from('chat_messages')
      .insert({
        'sender_id': currentUserId,
        'receiver_id': receiverId,
        'content': content,
        'is_read': false,
      })
      .select('*, sender:profiles!sender_id(avatar_url, username)')
      .single();
    
    final senderProfile = response['sender'];
    return ChatMessage(
      id: response['id'],
      senderId: response['sender_id'],
      receiverId: response['receiver_id'],
      content: response['content'],
      createdAt: DateTime.parse(response['created_at']),
      isRead: response['is_read'] ?? false,
      senderAvatarUrl: senderProfile?['avatar_url'],
      senderUsername: senderProfile?['username'],
    );
  }
  
  // Mark messages as read
  Future<void> markMessagesAsRead(String senderId) async {
    final currentUserId = _supabase.auth.currentUser!.id;
    
    await _supabase
      .from('chat_messages')
      .update({'is_read': true})
      .eq('sender_id', senderId)
      .eq('receiver_id', currentUserId)
      .eq('is_read', false);
  }
  
  // Subscribe to new messages
  Stream<ChatMessage> subscribeToMessages() {
    final currentUserId = _supabase.auth.currentUser!.id;
    final controller = StreamController<ChatMessage>.broadcast();
    
    _supabase
      .channel('public:chat_messages')
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'chat_messages',
          filter: 'receiver_id=eq.$currentUserId',
        ),
        (payload, [_]) {
          final data = payload['new'];
          final message = ChatMessage(
            id: data['id'],
            senderId: data['sender_id'],
            receiverId: data['receiver_id'],
            content: data['content'],
            createdAt: DateTime.parse(data['created_at']),
            isRead: data['is_read'] ?? false,
          );
          controller.add(message);
        },
      )
      .subscribe();
    
    return controller.stream;
  }
}

class ChatConversation {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
} 
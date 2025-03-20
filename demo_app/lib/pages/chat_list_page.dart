import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../models/chat_model.dart';
import '../models/profile_model.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final ProfileService _profileService = ProfileService();
  
  List<ChatConversation> _conversations = [];
  List<Profile> _allUsers = [];
  bool _isLoadingConversations = true;
  bool _isLoadingUsers = true;
  StreamSubscription? _messagesSubscription;
  
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConversations();
    _loadAllUsers();
    _setupRealtimeListener();
    
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoadingConversations = true;
    });

    try {
      final conversations = await _chatService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoadingConversations = false;
      });
    } catch (e) {
      print('Error loading conversations: $e');
      setState(() {
        _isLoadingConversations = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load conversations'))
      );
    }
  }
  
  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final users = await _profileService.getAllProfiles();
      final currentUserId = _supabase.auth.currentUser!.id;
      
      // Filter out the current user
      final filteredUsers = users.where((user) => user.id != currentUserId).toList();
      
      setState(() {
        _allUsers = filteredUsers;
        _isLoadingUsers = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      setState(() {
        _isLoadingUsers = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users'))
      );
    }
  }

  void _setupRealtimeListener() {
    // Listen for new messages
    _messagesSubscription = _chatService.subscribeToMessages().listen((message) {
      // Refresh the conversations when a new message is received
      _loadConversations();
    });
  }

  String _formatLastMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      // Today, show time
      return DateFormat.jm().format(time);
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week, show day name
      return DateFormat.E().format(time);
    } else {
      // Older, show date
      return DateFormat.yMd().format(time);
    }
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Navigate to chat detail
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(
                userId: conversation.userId,
                username: conversation.username,
                avatarUrl: conversation.avatarUrl,
              ),
            ),
          );
          // Refresh conversations when returning from chat detail
          _loadConversations();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: conversation.avatarUrl != null
                        ? NetworkImage(conversation.avatarUrl!)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: conversation.avatarUrl == null
                        ? Icon(Icons.person, size: 28, color: Colors.grey.shade400)
                        : null,
                  ),
                  if (conversation.unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16),
              
              // Message preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.username,
                          style: TextStyle(
                            fontWeight: conversation.unreadCount > 0 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatLastMessageTime(conversation.lastMessageTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: conversation.unreadCount > 0 
                                ? Colors.blue 
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      conversation.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: conversation.unreadCount > 0 
                            ? Colors.black 
                            : Colors.grey.shade600,
                        fontWeight: conversation.unreadCount > 0 
                            ? FontWeight.w500 
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserItem(Profile user) {
    final bool matchesSearch = _searchQuery.isEmpty || 
                             user.username?.toLowerCase().contains(_searchQuery) == true ||
                             user.fullName?.toLowerCase().contains(_searchQuery) == true;
    
    if (!matchesSearch) return SizedBox.shrink();
    
    return Card(
      elevation: 0,
      color: Colors.transparent,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Navigate to chat detail
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailPage(
                userId: user.id,
                username: user.username ?? 'User',
                avatarUrl: user.avatarUrl,
              ),
            ),
          );
          // Refresh conversations when returning from chat detail
          _loadConversations();
          _tabController.animateTo(0); // Switch to conversations tab
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: user.avatarUrl == null
                    ? Icon(Icons.person, size: 28, color: Colors.grey.shade400)
                    : null,
              ),
              SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username ?? 'User',
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    if (user.fullName != null && user.fullName!.isNotEmpty)
                      Text(
                        user.fullName!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    if (user.school != null && user.school!.isNotEmpty)
                      Text(
                        user.school!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Message button
              IconButton(
                icon: Icon(Icons.chat_bubble_outline, color: Colors.blue),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        userId: user.id,
                        username: user.username ?? 'User',
                        avatarUrl: user.avatarUrl,
                      ),
                    ),
                  );
                  _loadConversations();
                  _tabController.animateTo(0); // Switch to conversations tab
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyConversationsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_outlined,
              size: 64,
              color: Colors.blue.shade300,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Your conversations will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(1); // Switch to People tab
            },
            icon: Icon(Icons.people),
            label: Text('Find People to Chat With'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyUsersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.blue.shade300,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'There are no other users in the system yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users...',
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: [
            Tab(text: 'Chats'),
            Tab(text: 'People'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chats Tab
          RefreshIndicator(
            onRefresh: _loadConversations,
            color: Colors.blue,
            child: _isLoadingConversations
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : _conversations.isEmpty
                    ? _buildEmptyConversationsState()
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _conversations.length,
                        itemBuilder: (context, index) {
                          return _buildConversationItem(_conversations[index]);
                        },
                      ),
          ),
          
          // People Tab
          RefreshIndicator(
            onRefresh: _loadAllUsers,
            color: Colors.blue,
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _isLoadingUsers
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                        )
                      : _allUsers.isEmpty
                          ? _buildEmptyUsersState()
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              itemCount: _allUsers.length,
                              itemBuilder: (context, index) {
                                return _buildUserItem(_allUsers[index]);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
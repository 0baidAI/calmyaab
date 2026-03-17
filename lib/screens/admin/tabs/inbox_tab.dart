import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class InboxTab extends StatefulWidget {
  final String role;
  const InboxTab({super.key, required this.role});

  @override
  State<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends State<InboxTab> {
  String? _selectedUid;
  String _selectedName = '';
  final String _currentUid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ── Left contacts list ──────────────────────────────────────
        Container(
          width: 260,
          decoration: const BoxDecoration(
            color: AppColors.black2,
            border: Border(
                right: BorderSide(color: AppColors.whiteDim2)),
          ),
          child: Column(children: [
            // Header with unread badge
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('admin_messages')
                  .snapshots(),
              builder: (context, snapshot) {
                final allDocs = snapshot.data?.docs ?? [];
                final unread = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final fromUid = data['from_uid'] ?? '';
                  if (fromUid == _currentUid) return false;
                  if (data['to'] != 'all' &&
                      data['to'] != _currentUid) return false;
                  final readBy =
                      List<String>.from(data['read_by'] ?? []);
                  return !readBy.contains(_currentUid);
                }).length;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: AppColors.whiteDim2)),
                  ),
                  child: Row(children: [
                    Text('MESSAGES',
                        style: AppTextStyles.body(11,
                            color: AppColors.yellow,
                            weight: FontWeight.w700,
                            letterSpacing: 3,
                            height: 1)),
                    const Spacer(),
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('$unread',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                height: 1)),
                      ),
                  ]),
                );
              },
            ),

            // Contacts
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role',
                        whereIn: ['admin', 'super_admin'])
                    .snapshots(),
                builder: (context, snapshot) {
                  final allUsers = snapshot.data?.docs ?? [];
                  final others = allUsers
                      .where((d) => d.id != _currentUid)
                      .toList();

                  if (others.isEmpty) {
                    return Center(
                      child: Text('No team members yet',
                          style: AppTextStyles.body(13,
                              color: AppColors.gray)),
                    );
                  }

                  return ListView.builder(
                    itemCount: others.length,
                    itemBuilder: (_, i) {
                      final data = others[i].data()
                          as Map<String, dynamic>;
                      final isOpsHead =
                          data['role'] == 'super_admin';

                      return _ContactTile(
                        name: data['name'] ?? 'Team',
                        uid: others[i].id,
                        currentUid: _currentUid,
                        isSelected:
                            _selectedUid == others[i].id,
                        isOpsHead: isOpsHead,
                        onTap: () => setState(() {
                          _selectedUid = others[i].id;
                          _selectedName =
                              data['name'] ?? 'Team Member';
                        }),
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),

        // ── Right chat window ───────────────────────────────────────
        Expanded(
          child: _selectedUid == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('💬',
                          style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text('Select a team member to chat',
                          style: AppTextStyles.body(16,
                              color: AppColors.gray)),
                      const SizedBox(height: 8),
                      Text(
                          'All messages are private between you two',
                          style: AppTextStyles.body(13,
                              color: AppColors.gray2)),
                    ],
                  ),
                )
              : _ChatWindow(
                  currentUid: _currentUid,
                  recipientUid: _selectedUid!,
                  recipientName: _selectedName,
                ),
        ),
      ],
    );
  }
}

// ── Contact Tile ──────────────────────────────────────────────────────────────
class _ContactTile extends StatelessWidget {
  final String name, uid, currentUid;
  final bool isSelected, isOpsHead;
  final VoidCallback onTap;

  const _ContactTile({
    required this.name,
    required this.uid,
    required this.currentUid,
    required this.isSelected,
    required this.isOpsHead,
    required this.onTap,
  });

  String get _chatId {
    final ids = [currentUid, uid]..sort();
    return ids.join('_');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admin_chats')
          .doc(_chatId)
          .collection('messages')
          .orderBy('created_at', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        final msgs = snapshot.data?.docs ?? [];
        final lastMsg = msgs.isNotEmpty
            ? (msgs.first.data()
                as Map<String, dynamic>)['text'] ?? ''
            : '';

        // Count unread from this contact
        final unread = msgs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final readBy =
              List<String>.from(data['read_by'] ?? []);
          return data['from_uid'] != currentUid &&
              !readBy.contains(currentUid);
        }).length;

        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.yellowDim
                  : Colors.transparent,
              border: Border(
                left: BorderSide(
                  color: isSelected
                      ? AppColors.yellow
                      : Colors.transparent,
                  width: 3,
                ),
                bottom: const BorderSide(
                    color: AppColors.whiteDim2),
              ),
            ),
            child: Row(children: [
              // Avatar
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: isOpsHead
                      ? Colors.redAccent.withOpacity(0.15)
                      : AppColors.yellowDim,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOpsHead
                        ? Colors.redAccent.withOpacity(0.4)
                        : AppColors.yellowBorder,
                  ),
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 20,
                      color: isOpsHead
                          ? Colors.redAccent
                          : AppColors.yellow,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(name,
                            style: AppTextStyles.body(14,
                                weight: FontWeight.w600,
                                height: 1.2),
                            overflow: TextOverflow.ellipsis),
                      ),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius:
                                BorderRadius.circular(100),
                          ),
                          child: Text('$unread',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 1)),
                        ),
                    ]),
                    if (isOpsHead)
                      Text('Operations Head',
                          style: AppTextStyles.body(11,
                              color: Colors.redAccent,
                              height: 1.2)),
                    if (lastMsg.isNotEmpty)
                      Text(lastMsg,
                          style: AppTextStyles.body(12,
                              color: AppColors.gray,
                              height: 1.3),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ── Chat Window ───────────────────────────────────────────────────────────────
class _ChatWindow extends StatefulWidget {
  final String currentUid, recipientUid, recipientName;

  const _ChatWindow({
    required this.currentUid,
    required this.recipientUid,
    required this.recipientName,
  });

  @override
  State<_ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends State<_ChatWindow> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();

  String get _chatId {
    final ids = [widget.currentUid, widget.recipientUid]..sort();
    return ids.join('_');
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();

    final senderDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUid)
        .get();
    final senderName =
        senderDoc.data()?['name'] ?? 'Team';
    final now = DateTime.now().millisecondsSinceEpoch;

    await FirebaseFirestore.instance
        .collection('admin_chats')
        .doc(_chatId)
        .collection('messages')
        .add({
      'text':       text,
      'from_uid':   widget.currentUid,
      'from_name':  senderName,
      'created_at': now,
      'read_by':    [widget.currentUid],
    });

    await FirebaseFirestore.instance
        .collection('admin_chats')
        .doc(_chatId)
        .set({
      'participants': [widget.currentUid, widget.recipientUid],
      'last_message': text,
      'last_sender':  senderName,
      'updated_at':   now,
    }, SetOptions(merge: true));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Chat header
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: AppColors.black2,
          border: Border(
              bottom: BorderSide(color: AppColors.whiteDim2)),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.yellowDim,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.yellowBorder),
            ),
            child: Center(
              child: Text(
                widget.recipientName
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                    fontFamily: 'BebasNeue',
                    fontSize: 20,
                    color: AppColors.yellow,
                    height: 1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(widget.recipientName,
                style: AppTextStyles.body(15,
                    weight: FontWeight.w700, height: 1.2)),
            Text('● Online',
                style: AppTextStyles.body(11,
                    color: Colors.greenAccent, height: 1)),
          ]),
        ]),
      ),

      // Messages
      Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('admin_chats')
              .doc(_chatId)
              .collection('messages')
              .orderBy('created_at', descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.yellow));
            }

            final messages = snapshot.data?.docs ?? [];

            // Mark all as read
            for (final doc in messages) {
              final data =
                  doc.data() as Map<String, dynamic>;
              final readBy =
                  List<String>.from(data['read_by'] ?? []);
              if (!readBy.contains(widget.currentUid)) {
                doc.reference.update({
                  'read_by': FieldValue.arrayUnion(
                      [widget.currentUid]),
                });
              }
            }

            if (messages.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('👋',
                        style: TextStyle(fontSize: 36)),
                    const SizedBox(height: 12),
                    Text(
                        'Start chatting with ${widget.recipientName}',
                        style: AppTextStyles.body(14,
                            color: AppColors.gray)),
                  ],
                ),
              );
            }

            WidgetsBinding.instance
                .addPostFrameCallback((_) {
              if (_scrollCtrl.hasClients) {
                _scrollCtrl.jumpTo(
                    _scrollCtrl.position.maxScrollExtent);
              }
            });

            return ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final data = messages[i].data()
                    as Map<String, dynamic>;
                final isMe =
                    data['from_uid'] == widget.currentUid;
                final ts = data['created_at'] as int?;
                final date = ts != null
                    ? DateTime
                        .fromMillisecondsSinceEpoch(ts)
                    : DateTime.now();

                return _ChatBubble(
                  text: data['text'] ?? '',
                  senderName: data['from_name'] ?? '',
                  isMe: isMe,
                  time:
                      '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                );
              },
            );
          },
        ),
      ),

      // Input bar
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.black2,
          border: Border(
              top: BorderSide(color: AppColors.whiteDim2)),
        ),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: AppTextStyles.body(14,
                  color: AppColors.white),
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.body(14,
                    color: AppColors.gray2),
                filled: true,
                fillColor: AppColors.black3,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppColors.whiteDim2)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppColors.whiteDim2)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                        color: AppColors.yellow
                            .withOpacity(0.4))),
                contentPadding:
                    const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                color: AppColors.yellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded,
                  color: AppColors.black, size: 20),
            ),
          ),
        ]),
      ),
    ]);
  }
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final String text, senderName, time;
  final bool isMe;

  const _ChatBubble({
    required this.text,
    required this.senderName,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: AppColors.yellowDim,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.yellowBorder),
              ),
              child: Center(
                child: Text(
                  senderName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: 14,
                      color: AppColors.yellow,
                      height: 1),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.45,
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 4, bottom: 3),
                    child: Text(senderName,
                        style: AppTextStyles.body(11,
                            color: AppColors.yellow,
                            weight: FontWeight.w600,
                            height: 1)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? AppColors.yellow
                        : AppColors.black3,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    border: isMe
                        ? null
                        : Border.all(
                            color: AppColors.whiteDim2),
                  ),
                  child: Text(text,
                      style: AppTextStyles.body(14,
                          color: isMe
                              ? AppColors.black
                              : AppColors.white,
                          height: 1.5)),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 3, left: 4, right: 4),
                  child: Text(time,
                      style: AppTextStyles.body(10,
                          color: AppColors.gray2,
                          height: 1)),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
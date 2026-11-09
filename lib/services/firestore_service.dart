import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────────────────────────────────────────
  // ANNOUNCEMENTS
  // ─────────────────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getAnnouncementsStream() {
    return _db
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();
  }

  Future<void> postAnnouncement(
      {required String title,
      required String body,
      required String tag}) async {
    await _db.collection('announcements').add({
      'title': title,
      'body': body,
      'tag': tag,
      'createdAt': FieldValue.serverTimestamp(),
      'postedBy': _auth.currentUser?.uid ?? 'admin'
    });
  }

  Future<void> deleteAnnouncement(String docId) async {
    await _db.collection('announcements').doc(docId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // APPLICATIONS
  // ─────────────────────────────────────────────────────────────────────────────

  Future<String?> submitApplication(
      {required String name,
      required String email,
      required String phone,
      required String dob,
      required String address,
      required String gender,
      required String parentName,
      required String parentPhone,
      required String university,
      required String program,
      String? passportUrl,
      String? alResultUrl,
      String? olResultUrl,
      String? photoUrl,
      String? passportFileName,
      String? alResultFileName,
      String? olResultFileName,
      String? photoFileName}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return 'Not logged in.';
      final applicationRef = _db.collection('applications').doc(uid);
      final existing = await applicationRef.get();
      final existingData = existing.data();
      final existingStatus =
          existingData?['status'] as String? ?? 'Pending Review';
      final existingDocuments = existingData?['documents'] is Map
          ? Map<String, dynamic>.from(existingData?['documents'] as Map)
          : <String, dynamic>{};

      Map<String, dynamic> document(
        String key,
        String? url,
        String? fileName,
      ) {
        final previous = existingDocuments[key] is Map
            ? Map<String, dynamic>.from(existingDocuments[key] as Map)
            : <String, dynamic>{};
        return {
          'url': url ?? previous['url'],
          'fileName': fileName ?? previous['fileName'],
        };
      }

      final documents = {
        'passport': document('passport', passportUrl, passportFileName),
        'alResult': document('alResult', alResultUrl, alResultFileName),
        'olResult': document('olResult', olResultUrl, olResultFileName),
        'photo': document('photo', photoUrl, photoFileName),
      };
      final hasDocuments = documents.values.any(
        (item) => (item['url'] as String?)?.isNotEmpty == true,
      );
      await applicationRef.set({
        'name': name, 'email': email, 'phone': phone, 'dob': dob,
        'address': address, 'gender': gender, 'parentName': parentName,
        'parentPhone': parentPhone, 'university': university,
        'program': program,
        'status': existingStatus,
        'submittedAt': FieldValue.serverTimestamp(),
        'userId': uid,
        // Document URLs (Firebase Storage)
        'documents': documents,
        'documentsNote': hasDocuments
            ? 'Documents uploaded to storage'
            : 'Student will send documents via WhatsApp',
      });
      return null;
    } catch (e) {
      return 'Failed to submit application. Please check your connection.';
    }
  }

  Stream<QuerySnapshot> getAllApplicationsStream() {
    return _db
        .collection('applications')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  Future<void> updateApplicationStatus(String docId, String status) async {
    await _db.collection('applications').doc(docId).update({'status': status});
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MEDIA POSTS
  // ─────────────────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getMediaPostsStream() {
    return _db
        .collection('media_posts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots();
  }

  Future<void> addMediaPost(
      {required String title,
      required String desc,
      required String tag,
      required String emoji,
      String? videoUrl}) async {
    await _db.collection('media_posts').add({
      'title': title,
      'desc': desc,
      'tag': tag,
      'emoji': emoji,
      if (videoUrl != null && videoUrl.isNotEmpty) 'videoUrl': videoUrl,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  Future<void> deleteMediaPost(String docId) async {
    await _db.collection('media_posts').doc(docId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STUDENT PROGRESS
  // ─────────────────────────────────────────────────────────────────────────────

  Stream<DocumentSnapshot> getStudentProgressStream(String userId) {
    return _db.collection('student_progress').doc(userId).snapshots();
  }

  Future<void> saveStudentProgress(
      {required String userId,
      required String semester,
      required String gpa,
      required int overallAttendance,
      required int labAttendance,
      required List<Map<String, dynamic>> subjects}) async {
    await _db.collection('student_progress').doc(userId).set({
      'semester': semester,
      'gpa': gpa,
      'overallAttendance': overallAttendance,
      'labAttendance': labAttendance,
      'subjects': subjects,
      'updatedAt': FieldValue.serverTimestamp()
    });
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // STUDENT FEE RECORDS
  // ─────────────────────────────────────────────────────────────────────────────

  Stream<DocumentSnapshot> getStudentFeesStream(String userId) {
    return _db.collection('student_fees').doc(userId).snapshots();
  }

  Future<void> saveStudentFees(
      {required String userId,
      required List<Map<String, dynamic>> items}) async {
    await _db
        .collection('student_fees')
        .doc(userId)
        .set({'items': items, 'updatedAt': FieldValue.serverTimestamp()});
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MEETINGS
  // ─────────────────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getMeetingsStream() {
    return _db.collection('meetings').orderBy('order').snapshots();
  }

  Future<QuerySnapshot> getMeetingsFuture() {
    return _db.collection('meetings').orderBy('order').get();
  }

  Future<void> addMeeting(Map<String, dynamic> data) async {
    await _db
        .collection('meetings')
        .add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateMeeting(String docId, Map<String, dynamic> data) async {
    await _db.collection('meetings').doc(docId).update(data);
  }

  Future<void> deleteMeeting(String docId) async {
    await _db.collection('meetings').doc(docId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // NEWS ARTICLES
  // ─────────────────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getNewsArticlesStream() {
    return _db
        .collection('news_articles')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addNewsArticle(Map<String, dynamic> data) async {
    await _db
        .collection('news_articles')
        .add({...data, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateNewsArticle(
      String docId, Map<String, dynamic> data) async {
    await _db.collection('news_articles').doc(docId).update(data);
  }

  Future<void> deleteNewsArticle(String docId) async {
    await _db.collection('news_articles').doc(docId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // SEED DATA
  // ─────────────────────────────────────────────────────────────────────────────

  Future<void> seedInitialData() async {
    // Announcements
    final announcementsRef = _db.collection('announcements');
    if ((await announcementsRef.limit(1).get()).docs.isEmpty) {
      for (final a in [
        {
          'title': '📢 2025 Intake Now Open!',
          'body':
              'Applications for YSMU Medical Program September 2025 intake are now open. Limited seats available.',
          'tag': 'Intake',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 15))
        },
        {
          'title': '🎓 Scholarship Exam - June 2025',
          'body':
              'Scholarship examination for eligible students will be held on June 20, 2025. Register now!',
          'tag': 'Scholarship',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 10))
        },
        {
          'title': '✈️ Free Airport Pickup',
          'body':
              'All new students flying to Yerevan will receive complimentary airport pickup service.',
          'tag': 'Info',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 8))
        },
        {
          'title': '👨‍👩‍👧 Parent Meeting - June 5',
          'body':
              'Online parent information session via Google Meet on June 5, 2025 at 7:00 PM (Sri Lanka Time).',
          'tag': 'Event',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 5))
        },
      ]) {
        await announcementsRef.add(a);
      }
    }

    // Media posts
    final mediaRef = _db.collection('media_posts');
    for (var doc in (await mediaRef.get()).docs) {
      await doc.reference.delete();
    }
    final posts = [
      {
        'title': 'First Snow Experience ❄️',
        'desc':
            'Sri Lankan students experiencing snow for the first time in Yerevan! The joy on their faces is priceless.',
        'tag': 'Student Life',
        'emoji': '❄️',
        'imageUrl': 'assets/images/media_snow.png',
        'likes': 342,
        'createdAt': Timestamp.fromDate(DateTime(2024, 12, 15)),
      },
      {
        'title': 'Medical Practical Training 🏥',
        'desc':
            'YSMU students completing their clinical training at Yerevan City Hospital.',
        'tag': 'Academic',
        'emoji': '🏥',
        'imageUrl': 'assets/images/media_medical.png',
        'likes': 215,
        'createdAt': Timestamp.fromDate(DateTime(2024, 11, 28)),
      },
      {
        'title': 'Graduation Ceremony 🎓',
        'desc':
            'Congratulations to our 2024 batch graduates! 15 Sri Lankan students graduated from YSMU today.',
        'tag': 'Graduation',
        'emoji': '🎓',
        'imageUrl': 'assets/images/media_graduation.png',
        'likes': 520,
        'createdAt': Timestamp.fromDate(DateTime(2024, 10, 20)),
      },
      {
        'title': 'Airport Arrival & Welcome 🛬',
        'desc':
            'September 2024 batch welcomed at Zvartnots International Airport, Yerevan.',
        'tag': 'New Intake',
        'emoji': '🛬',
        'imageUrl': 'assets/images/media_airport.png',
        'likes': 412,
        'createdAt': Timestamp.fromDate(DateTime(2024, 9, 1)),
      },
    ];
    for (final p in posts) {
      await mediaRef.add(p);
    }

    // Meetings
    final meetingsRef = _db.collection('meetings');
    if ((await meetingsRef.limit(1).get()).docs.isEmpty) {
      final meetings = [
        {
          'title': 'Monthly Parent Information Meeting',
          'date': 'JUN 5, 2025',
          'time': '7:00 PM – 8:00 PM (SL Time)',
          'host': 'Armenia Lanka Education Team',
          'status': 'Upcoming',
          'meetUrl': 'https://meet.google.com',
          'canJoin': true,
          'order': 1,
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 20))
        },
        {
          'title': 'Mid-Year Academic Review Session',
          'date': 'JUL 3, 2025',
          'time': '6:30 PM – 7:30 PM (SL Time)',
          'host': 'Dr. Rajapaksha / YSMU Liaison',
          'status': 'Upcoming',
          'meetUrl': 'https://meet.google.com',
          'canJoin': false,
          'order': 2,
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 20))
        },
        {
          'title': 'September 2025 Intake – Pre-Departure Briefing',
          'date': 'MAY 2, 2025',
          'time': '7:00 PM – 8:15 PM (SL Time)',
          'host': 'Armenia Lanka Education Team',
          'status': 'Completed',
          'meetUrl': '',
          'canJoin': false,
          'order': 3,
          'createdAt': Timestamp.fromDate(DateTime(2025, 4, 20))
        },
        {
          'title': 'Visa & Documentation Q&A Session',
          'date': 'APR 10, 2025',
          'time': '7:00 PM – 8:00 PM (SL Time)',
          'host': 'Embassy Coordinator — Mr. Perera',
          'status': 'Completed',
          'meetUrl': '',
          'canJoin': false,
          'order': 4,
          'createdAt': Timestamp.fromDate(DateTime(2025, 4, 1))
        },
      ];
      for (final m in meetings) {
        await meetingsRef.add(m);
      }
    }

    // News articles
    final newsRef = _db.collection('news_articles');
    if ((await newsRef.limit(1).get()).docs.isEmpty) {
      final articles = [
        {
          'title':
              'YSMU Ranked Among Top 200 Medical Universities in Eastern Europe',
          'body':
              'Yerevan State Medical University has been ranked among the top 200 medical universities in Eastern Europe by the QS World University Rankings 2025.',
          'tag': 'Academic',
          'emoji': '🏆',
          'date': 'June 3, 2025',
          'createdAt': Timestamp.fromDate(DateTime(2025, 6, 3))
        },
        {
          'title': 'September 2025 Batch Visa Processing Has Begun',
          'body':
              'The Armenian Embassy has begun processing student visas for the September 2025 intake. All students who have submitted their documents will receive their visas before the departure date.',
          'tag': 'Visa',
          'emoji': '🛂',
          'date': 'May 28, 2025',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 28))
        },
        {
          'title':
              'Mandatory Health Insurance Package for 2025–26 Academic Year',
          'body':
              'All international students at YSMU are required to have comprehensive health insurance. Group package available at USD 180 per year.',
          'tag': 'Health',
          'emoji': '🏥',
          'date': 'May 20, 2025',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 20))
        },
        {
          'title': 'New Installment Payment Plan Available for Tuition',
          'body':
              'Armenia Lanka Education now offers a 3-installment payment plan for YSMU tuition fees divided across September, January, and April.',
          'tag': 'Finance',
          'emoji': '💰',
          'date': 'May 15, 2025',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 15))
        },
        {
          'title': 'Sri Lankan Students Celebrate Vesak in Yerevan',
          'body':
              'Our Sri Lankan student community organized a beautiful Vesak celebration at the student dormitory in Yerevan.',
          'tag': 'Student Life',
          'emoji': '🪔',
          'date': 'May 10, 2025',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 10))
        },
        {
          'title':
              'YSMU Announces Clinical Training Partnership with Yerevan City Hospital',
          'body':
              'From Year 3 onwards, YSMU students will undergo clinical training at the newly renovated Yerevan City Hospital.',
          'tag': 'Academic',
          'emoji': '🔬',
          'date': 'May 5, 2025',
          'createdAt': Timestamp.fromDate(DateTime(2025, 5, 5))
        },
      ];
      for (final a in articles) {
        await newsRef.add(a);
      }
    }
  }
}

class University {
  final String id;
  final String name;
  final String shortName;
  final String category;
  final String description;
  final String history;
  final String accreditation;
  final String ranking;
  final List<String> faculties;
  final String degreeDuration;
  final int sriLankanStudents;
  final double tuitionFeeUSD;
  final double hostelFeeUSD;
  final double insuranceFeeUSD;
  final double visaFeeUSD;
  final List<String> benefits;
  final List<String> testimonials;
  final String imageUrl;
  final String location;
  final bool hasEnglishMedium;
  final bool noIeltsRequired;
  final String contactEmail;
  final String whatsapp;

  University({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.description,
    required this.history,
    required this.accreditation,
    required this.ranking,
    required this.faculties,
    required this.degreeDuration,
    required this.sriLankanStudents,
    required this.tuitionFeeUSD,
    required this.hostelFeeUSD,
    required this.insuranceFeeUSD,
    required this.visaFeeUSD,
    required this.benefits,
    required this.testimonials,
    required this.imageUrl,
    required this.location,
    required this.hasEnglishMedium,
    required this.noIeltsRequired,
    required this.contactEmail,
    required this.whatsapp,
  });
}

class UniversityData {
  static List<University> getUniversities() {
    return [
      University(
        id: 'ysmu',
        name: 'Yerevan State Medical University',
        shortName: 'YSMU',
        category: 'Medical',
        description:
            'Founded in 1920, YSMU is the oldest and most prestigious government medical institution in Armenia, recognized by WHO and Medical Councils worldwide.',
        history:
            'Established in 1920, YSMU has over 100 years of excellence. It operates its own university hospitals providing direct clinical exposure.',
        accreditation:
            'WHO Listed | MCI/NMC Recognized | European Medical Council | FAIMER Listed',
        ranking: 'Top 5% Medical Universities in Eastern Europe',
        faculties: [
          'General Medicine (MBBS)',
          'Dentistry (BDS)',
          'Pharmacy',
          'Public Health',
          'Pre-medical Course',
        ],
        degreeDuration: '6 Years (MBBS) | 5 Years (Dentistry)',
        sriLankanStudents: 450,
        tuitionFeeUSD: 6500,
        hostelFeeUSD: 1000,
        insuranceFeeUSD: 150,
        visaFeeUSD: 150,
        benefits: [
          'No IELTS Required',
          'English Medium Instruction',
          'University-owned Hospitals',
          'International Student Hostels',
          'Pre-medical Preparatory Courses',
          'Sri Lankan Student Community',
          'Free Breakfast Provided',
        ],
        testimonials: [
          'Best decision of my life. The faculty is excellent and Sri Lankan student community is very supportive. - Kasun, 4th Year Student',
          'Affordable fees with world-class clinical exposure. My parents are very happy. - Nimali, Graduated 2023',
        ],
        imageUrl: 'assets/images/ysmu.jpg',
        location: 'Yerevan, Armenia',
        hasEnglishMedium: true,
        noIeltsRequired: true,
        contactEmail: 'info@armenialanka.com',
        whatsapp: '+94771234567',
      ),
      University(
        id: 'seua',
        name: 'State Engineering University of Armenia',
        shortName: 'SEUA',
        category: 'Engineering',
        description:
            'The premier engineering university in Armenia offering cutting-edge programs in civil, electrical, mechanical and computer engineering.',
        history:
            'Established in 1933, SEUA has been the backbone of Armenian engineering education and technological development for nearly a century.',
        accreditation:
            'Ministry of Education Armenia | ABET Recognized Programs | EUR-ACE Label',
        ranking: 'Top Engineering University in the South Caucasus',
        faculties: [
          'Civil Engineering',
          'Electrical Engineering',
          'Mechanical Engineering',
          'Computer Science',
          'Automation & Control',
          'Industrial Management',
        ],
        degreeDuration: '4 Years (Bachelor) | 2 Years (Master)',
        sriLankanStudents: 85,
        tuitionFeeUSD: 3200,
        hostelFeeUSD: 1000,
        insuranceFeeUSD: 180,
        visaFeeUSD: 150,
        benefits: [
          'No IELTS Required',
          'English Medium Programs',
          'Modern Labs & Workshops',
          'Industry Internships',
          'Airport Pickup',
          'Hostel Accommodation',
          'Visa Guidance',
          'Scholarship Opportunities',
        ],
        testimonials: [
          'The engineering labs are world-class. I got a job offer before graduation. - Thilina, CS Graduate',
          'Very affordable compared to other countries. Education quality is excellent. - Sachini, Civil Engineering',
        ],
        imageUrl: 'assets/images/seua.jpg',
        location: 'Yerevan, Armenia',
        hasEnglishMedium: true,
        noIeltsRequired: true,
        contactEmail: 'info@armenialanka.com',
        whatsapp: '+94771234567',
      ),
      University(
        id: 'aua',
        name: 'American University of Armenia',
        shortName: 'AUA',
        category: 'IT & Business',
        description:
            'A US-accredited university offering American-style education in IT, Business, and Law in the heart of Yerevan.',
        history:
            'Founded in 1991 as a joint venture between Armenia and the University of California, AUA provides globally recognized American education.',
        accreditation: 'WASC Accredited | University of California Affiliated',
        ranking: 'Top 3 Universities in Armenia | Globally Recognized',
        faculties: [
          'Computer & Information Science',
          'Business Administration (MBA)',
          'Law',
          'Industrial Engineering',
          'Data Science',
          'Political Science',
        ],
        degreeDuration: '4 Years (Bachelor) | 2 Years (Master)',
        sriLankanStudents: 60,
        tuitionFeeUSD: 6500,
        hostelFeeUSD: 1500,
        insuranceFeeUSD: 250,
        visaFeeUSD: 150,
        benefits: [
          'US Accredited Degree',
          'English Medium',
          'American Teaching Style',
          'Silicon Valley Connections',
          'Tech Startup Hub',
          'International Internships',
          'Global Alumni Network',
        ],
        testimonials: [
          'Got my dream job in a US tech company after graduating from AUA. - Dinusha, CS Graduate',
          'The MBA program opened doors to international business opportunities. - Pradeep, MBA Alumni',
        ],
        imageUrl: 'assets/images/aua.jpg',
        location: 'Yerevan, Armenia',
        hasEnglishMedium: true,
        noIeltsRequired: false,
        contactEmail: 'info@armenialanka.com',
        whatsapp: '+94771234567',
      ),
      University(
        id: 'nuaca',
        name: 'National University of Architecture and Construction of Armenia',
        shortName: 'NUACA',
        category: 'Architecture',
        description:
            'Armenia\'s leading public university for architecture, construction, and design. The first university in Armenia to achieve European accreditation (HCERES & ANECA).',
        history:
            'Originating from Yerevan State University in 1921, NUACA has a century of history in training skilled, internationally competitive professionals.',
        accreditation:
            'HCERES (France) | ANECA (Spain) | Ministry of Education',
        ranking: 'Top Architecture & Construction University in Armenia',
        faculties: [
          'Architecture',
          'Civil Engineering',
          'Design',
          'Urban Economy and Ecology',
          'Management and Technologies',
        ],
        degreeDuration: '4 Years (Bachelor) | 2 Years (Master)',
        sriLankanStudents: 30,
        tuitionFeeUSD: 2000,
        hostelFeeUSD: 800,
        insuranceFeeUSD: 150,
        visaFeeUSD: 150,
        benefits: [
          'No IELTS Required (Interview based)',
          'English Medium Programs Available',
          'European Accredited Degrees',
          'Architecture diplomas recognized by French Gov.',
          'Modern Labs (AutoCAD, Revit, Civil 3D)',
          'Over 80 International Partner Universities',
        ],
        testimonials: [
          'Learning architecture at NUACA is an incredible experience. Ancient and modern merge beautifully here. - Kavinda, 3rd Year',
        ],
        imageUrl: 'assets/images/naa.jpg',
        location: 'Yerevan, Armenia',
        hasEnglishMedium: true,
        noIeltsRequired: true,
        contactEmail: 'info@armenialanka.com',
        whatsapp: '+94771234567',
      ),
      University(
        id: 'ysu_tourism',
        name: 'Yerevan State University - Tourism & Hospitality',
        shortName: 'YSU Tourism',
        category: 'Tourism & Hospitality',
        description:
            'Armenia\'s growing tourism sector creates excellent career opportunities for graduates in hospitality and tourism management.',
        history:
            'Part of Yerevan State University, the oldest and largest university in Armenia founded in 1919.',
        accreditation:
            'Ministry of Education Armenia | UNWTO TedQual Recognized',
        ranking: 'Top Tourism Program in the Caucasus',
        faculties: [
          'Tourism Management',
          'Hotel Management',
          'Event Management',
          'Culinary Arts',
          'Travel & Aviation Management',
        ],
        degreeDuration: '4 Years (Bachelor)',
        sriLankanStudents: 45,
        tuitionFeeUSD: 2800,
        hostelFeeUSD: 900,
        insuranceFeeUSD: 150,
        visaFeeUSD: 150,
        benefits: [
          'No IELTS Required',
          'Practical Hotel Training',
          'Internship in 5-Star Hotels',
          'International Tourism Network',
          'Airport Pickup',
          'English Medium',
        ],
        testimonials: [
          'Armenia is a beautiful country and studying tourism here gave me hands-on experience in one of the fastest growing tourism sectors. - Manoja, Tourism Graduate',
        ],
        imageUrl: 'assets/images/ysu.jpg',
        location: 'Yerevan, Armenia',
        hasEnglishMedium: true,
        noIeltsRequired: true,
        contactEmail: 'info@armenialanka.com',
        whatsapp: '+94771234567',
      ),
    ];
  }
}

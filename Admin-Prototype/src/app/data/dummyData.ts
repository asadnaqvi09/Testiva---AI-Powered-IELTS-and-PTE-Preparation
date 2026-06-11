// ─── Users ────────────────────────────────────────────────────────────────────
export const dummyUsers = [
  { id: 'USR101', name: 'Ahmed Raza', email: 'ahmed.raza@example.com', role: 'registered', subscription: 'premium', lastActive: '2026-03-05', status: 'active', score: 87, assignedTest: 'IELTS', institute: 'INS1' },
  { id: 'USR102', name: 'Fatima Noor', email: 'fatima.noor@example.com', role: 'registered', subscription: 'free', lastActive: '2026-03-04', status: 'active', score: 72, assignedTest: 'TOEFL', institute: 'INS1' },
  { id: 'USR103', name: 'Bilal Siddiqui', email: 'bilal.s@example.com', role: 'registered', subscription: 'premium', lastActive: '2026-03-03', status: 'active', score: 91, assignedTest: 'IELTS', institute: 'INS2' },
  { id: 'USR104', name: 'Ayesha Tariq', email: 'ayesha.t@example.com', role: 'registered', subscription: 'free', lastActive: '2026-02-28', status: 'inactive', score: 65, assignedTest: 'PTE', institute: 'INS1' },
  { id: 'USR105', name: 'Usman Malik', email: 'usman.m@example.com', role: 'registered', subscription: 'basic', lastActive: '2026-03-01', status: 'active', score: 78, assignedTest: 'IELTS', institute: 'INS2' },
  { id: 'USR106', name: 'Sana Sheikh', email: 'sana.s@example.com', role: 'registered', subscription: 'free', lastActive: '2026-02-27', status: 'active', score: 69, assignedTest: 'TOEFL', institute: 'INS3' },
  { id: 'USR107', name: 'Kamran Ali', email: 'kamran.ali@example.com', role: 'registered', subscription: 'premium', lastActive: '2026-03-05', status: 'active', score: 95, assignedTest: 'IELTS', institute: 'INS1' },
  { id: 'USR108', name: 'Hira Baig', email: 'hira.b@example.com', role: 'registered', subscription: 'basic', lastActive: '2026-03-02', status: 'active', score: 82, assignedTest: 'PTE', institute: 'INS2' },
  { id: 'USR109', name: 'Zaid Hussain', email: 'zaid.h@example.com', role: 'registered', subscription: 'free', lastActive: '2026-02-25', status: 'inactive', score: 58, assignedTest: 'TOEFL', institute: 'INS3' },
  { id: 'USR110', name: 'Maryam Iqbal', email: 'maryam.i@example.com', role: 'registered', subscription: 'premium', lastActive: '2026-03-04', status: 'active', score: 88, assignedTest: 'IELTS', institute: 'INS1' },
];

// ─── Institutes (B2B) ─────────────────────────────────────────────────────────
export const dummyInstitutes = [
  { id: 'INS1', slug: 'INS1-ABB', name: 'Abbottabad Academy', adminEmail: 'instituteadmin@example.com', students: 45, plan: 'Premium', status: 'active', fee: 25000, joinDate: '2025-09-01' },
  { id: 'INS2', slug: 'INS2-KHI', name: 'Karachi Prep Center', adminEmail: 'khi.admin@example.com', students: 62, plan: 'Basic', status: 'active', fee: 15000, joinDate: '2025-10-15' },
  { id: 'INS3', slug: 'INS3-LHR', name: 'Lahore Language Hub', adminEmail: 'lhr.admin@example.com', students: 38, plan: 'Premium', status: 'active', fee: 25000, joinDate: '2025-11-01' },
  { id: 'INS4', slug: 'INS4-ISL', name: 'Islamabad English Center', adminEmail: 'isl.admin@example.com', students: 28, plan: 'Basic', status: 'inactive', fee: 15000, joinDate: '2025-08-20' },
  { id: 'INS5', slug: 'INS5-PES', name: 'Peshawar Test Hub', adminEmail: 'pes.admin@example.com', students: 19, plan: 'Basic', status: 'active', fee: 15000, joinDate: '2026-01-10' },
];

// ─── Mock Tests ────────────────────────────────────────────────────────────────
export const dummyMocks = [
  {
    id: 'MCK001', title: 'IELTS Reading Mock #1', testType: 'IELTS', sections: ['Reading', 'Writing', 'Listening', 'Speaking'],
    questionsCount: 40, duration: 60, difficulty: 'Medium', createdDate: '2026-02-10', status: 'published',
    questions: [
      { id: 'Q1', text: 'What is the main purpose of the passage?', type: 'MCQ', options: ['To inform', 'To entertain', 'To persuade', 'To describe'], answer: 'To inform', difficulty: 'Easy' },
      { id: 'Q2', text: 'Which word is closest in meaning to "benevolent"?', type: 'MCQ', options: ['Kind', 'Cruel', 'Indifferent', 'Harsh'], answer: 'Kind', difficulty: 'Medium' },
    ]
  },
  {
    id: 'MCK002', title: 'TOEFL Reading Mock #1', testType: 'TOEFL', sections: ['Reading', 'Listening', 'Speaking', 'Writing'],
    questionsCount: 36, duration: 54, difficulty: 'Hard', createdDate: '2026-02-15', status: 'published',
    questions: []
  },
  {
    id: 'MCK003', title: 'PTE Academic Practice #1', testType: 'PTE', sections: ['Speaking & Writing', 'Reading', 'Listening'],
    questionsCount: 45, duration: 120, difficulty: 'Medium', createdDate: '2026-02-20', status: 'draft',
    questions: []
  },
  {
    id: 'MCK004', title: 'IELTS General Mock #2', testType: 'IELTS', sections: ['Reading', 'Writing'],
    questionsCount: 27, duration: 60, difficulty: 'Easy', createdDate: '2026-03-01', status: 'published',
    questions: []
  },
  {
    id: 'MCK005', title: 'TOEFL Listening Mock #2', testType: 'TOEFL', sections: ['Listening', 'Speaking'],
    questionsCount: 22, duration: 40, difficulty: 'Medium', createdDate: '2026-03-03', status: 'draft',
    questions: []
  },
];

// ─── Preparation Content ───────────────────────────────────────────────────────
export const dummyPrep = [
  {
    id: 'PREP001', title: 'IELTS Academic Reading: Skimming & Scanning', testType: 'IELTS', section: 'Reading',
    summary: 'Learn techniques for skimming and scanning to identify key info quickly.', date: '2026-02-05', status: 'published',
    parts: 3,
    partsDetail: [
      { title: 'Introduction to Skimming', content: 'Skimming involves reading quickly to get the general idea of a text without focusing on every word...' },
      { title: 'Scanning Techniques', content: 'Scanning is used to locate specific information. Move your eyes quickly across the text looking for keywords...' },
      { title: 'Practice Exercises', content: 'Try these 5 passages to practice your skimming and scanning skills with timed exercises...' },
    ],
    mediaFiles: [{ name: 'IELTS_Reading_Guide.pdf', size: '2.4 MB' }, { name: 'Practice_Passages.pdf', size: '1.1 MB' }],
    instituteOnly: false,
  },
  {
    id: 'PREP002', title: 'IELTS Writing Task 2: Essay Structure', testType: 'IELTS', section: 'Writing',
    summary: 'A comprehensive guide to structuring IELTS Writing Task 2 essays.', date: '2026-02-10', status: 'published',
    parts: 5,
    partsDetail: [
      { title: 'Understanding the Prompt', content: 'Analyze the question type: Opinion, Discussion, Problem-Solution, or Advantages/Disadvantages...' },
      { title: 'Introduction Paragraph', content: 'Paraphrase the question and state your thesis clearly in 2-3 sentences...' },
      { title: 'Body Paragraphs', content: 'Each body paragraph should have a topic sentence, supporting details, and examples...' },
      { title: 'Conclusion Writing', content: 'Summarize your main points without introducing new ideas...' },
      { title: 'Sample Essays', content: 'Band 9 sample essays with annotations for each essay type...' },
    ],
    mediaFiles: [{ name: 'Writing_Task2_Templates.pdf', size: '890 KB' }],
    instituteOnly: false,
  },
  {
    id: 'PREP003', title: 'TOEFL Listening: Note-Taking Strategies', testType: 'TOEFL', section: 'Listening',
    summary: 'Effective note-taking methods for TOEFL Listening section.', date: '2026-02-18', status: 'published',
    parts: 4,
    partsDetail: [
      { title: 'Why Note-Taking Matters', content: 'TOEFL Listening questions often test details mentioned only once. Notes help retain information...' },
      { title: 'Abbreviation Systems', content: 'Use shorthand symbols and abbreviations to write faster. Common symbols: → (leads to), ↑ (increase)...' },
      { title: 'Lecture vs Conversation Notes', content: 'Lectures require structured notes with main topic and subtopics. Conversations need dialogue tracking...' },
      { title: 'Practice Audio Sets', content: 'Listen to 3 academic lectures and practice your note-taking with the included answer keys...' },
    ],
    mediaFiles: [{ name: 'Note_Taking_Workbook.pdf', size: '1.7 MB' }, { name: 'Audio_Transcripts.pdf', size: '560 KB' }],
    instituteOnly: false,
  },
  {
    id: 'PREP004', title: 'PTE Speaking: Read Aloud Tips', testType: 'PTE', section: 'Speaking',
    summary: 'Practice oral fluency with expert tips for PTE Read Aloud tasks.', date: '2026-02-25', status: 'draft',
    parts: 2,
    partsDetail: [
      { title: 'Pacing and Pronunciation', content: 'Read at a natural pace. Avoid rushing. Focus on word stress and sentence intonation...' },
      { title: 'Common Mistakes', content: 'Skipping punctuation pauses, misreading numbers, and poor microphone setup are top errors...' },
    ],
    mediaFiles: [],
    instituteOnly: true,
  },
  {
    id: 'PREP005', title: 'IELTS Vocabulary Builder – Academic Word List', testType: 'IELTS', section: 'Reading',
    summary: '500 academic words with definitions, examples and memory tricks.', date: '2026-03-01', status: 'published',
    parts: 6,
    partsDetail: [
      { title: 'Words A–D', content: 'Abandon, Abstract, Accommodate, Adequate, Adjacent...' },
      { title: 'Words E–H', content: 'Emerge, Empirical, Enormous, Establish, Evaluate...' },
      { title: 'Words I–M', content: 'Identify, Impact, Indicate, Institute, Interpret...' },
      { title: 'Words N–R', content: 'Notion, Obtain, Perceive, Principle, Require...' },
      { title: 'Words S–V', content: 'Significant, Specific, Structure, Theory, Tradition...' },
      { title: 'Practice Tests', content: 'Fill-in-the-blank, matching, and definition exercises for all 500 words...' },
    ],
    mediaFiles: [{ name: 'Academic_Word_List.pdf', size: '3.2 MB' }],
    instituteOnly: false,
  },
  {
    id: 'PREP006', title: 'TOEFL Speaking: Independent Task Guide', testType: 'TOEFL', section: 'Speaking',
    summary: 'How to organize your thoughts and speak fluently in 45 seconds.', date: '2026-03-03', status: 'published',
    parts: 3,
    partsDetail: [
      { title: 'Task Overview', content: 'The independent task asks you to express and defend your personal opinion on a familiar topic...' },
      { title: 'PREP Framework', content: 'Point, Reason, Example, Point restated. Use this 4-step structure for all responses...' },
      { title: 'Scored Samples', content: 'Audio samples scored 1–5 with annotated transcripts showing what raters look for...' },
    ],
    mediaFiles: [{ name: 'Speaking_Rubric.pdf', size: '420 KB' }, { name: 'Sample_Responses.pdf', size: '1.3 MB' }],
    instituteOnly: false,
  },
];

// ─── Community Posts ──────────────────────────────────────────────────────────
export const dummyCommunityPosts = [
  { id: 'POST001', user: 'ahmed.raza@example.com', content: 'Can anyone share IELTS Writing Task 2 tips for academic essays?', likes: 12, replies: 5, date: '2026-03-05', flagged: false },
  { id: 'POST002', user: 'fatima.noor@example.com', content: 'Just scored 7.5 on IELTS! The mock tests really helped.', likes: 34, replies: 12, date: '2026-03-04', flagged: false },
  { id: 'POST003', user: 'zaid.h@example.com', content: 'This platform is useless! No one responds to queries. Absolute trash!', likes: 1, replies: 0, date: '2026-03-04', flagged: true },
  { id: 'POST004', user: 'hira.b@example.com', content: 'Looking for a study partner for PTE preparation.', likes: 8, replies: 3, date: '2026-03-03', flagged: false },
  { id: 'POST005', user: 'kamran.ali@example.com', content: 'The TOEFL listening section improved my comprehension skills significantly.', likes: 21, replies: 7, date: '2026-03-03', flagged: false },
  { id: 'POST006', user: 'sana.s@example.com', content: 'Can we get more practice materials for TOEFL writing?', likes: 6, replies: 2, date: '2026-03-02', flagged: false },
  { id: 'POST007', user: 'bilal.s@example.com', content: 'SPAM SPAM visit our site for free IELTS materials...', likes: 0, replies: 0, date: '2026-03-02', flagged: true },
  { id: 'POST008', user: 'maryam.i@example.com', content: 'The vocabulary builder is amazing! Highly recommended.', likes: 15, replies: 4, date: '2026-03-01', flagged: false },
  { id: 'POST009', user: 'usman.m@example.com', content: 'How many mock tests should I do per week to prepare for IELTS?', likes: 9, replies: 6, date: '2026-02-28', flagged: false },
  { id: 'POST010', user: 'ayesha.t@example.com', content: 'Can we get a dark mode for the app?', likes: 27, replies: 10, date: '2026-02-27', flagged: false },
];

// ─── Subscriptions ────────────────────────────────────────────────────────────
export const dummySubscriptions = [
  { id: 'SUB001', userId: 'USR101', name: 'Ahmed Raza', plan: 'Premium', startDate: '2026-01-01', endDate: '2026-12-31', status: 'active', amount: 699, tests: 'All Tests' },
  { id: 'SUB002', userId: 'USR103', name: 'Bilal Siddiqui', plan: 'Premium', startDate: '2026-01-15', endDate: '2026-12-14', status: 'active', amount: 699, tests: 'All Tests' },
  { id: 'SUB003', userId: 'USR105', name: 'Usman Malik', plan: 'Basic', startDate: '2026-02-01', endDate: '2026-07-31', status: 'active', amount: 399, tests: 'IELTS' },
  { id: 'SUB004', userId: 'USR107', name: 'Kamran Ali', plan: 'Premium', startDate: '2025-12-01', endDate: '2026-11-30', status: 'active', amount: 699, tests: 'All Tests' },
  { id: 'SUB005', userId: 'USR108', name: 'Hira Baig', plan: 'Basic', startDate: '2026-01-20', endDate: '2026-06-19', status: 'active', amount: 399, tests: 'IELTS' },
  { id: 'SUB006', userId: 'USR110', name: 'Maryam Iqbal', plan: 'Premium', startDate: '2026-02-10', endDate: '2027-02-09', status: 'active', amount: 699, tests: 'All Tests' },
  { id: 'SUB007', userId: 'USR104', name: 'Ayesha Tariq', plan: 'Free', startDate: '2026-01-05', endDate: 'N/A', status: 'free', amount: 0, tests: 'Limited' },
];

// ─── Analytics ────────────────────────────────────────────────────────────────
export const userGrowthData = [
  { month: 'Sep', users: 30 }, { month: 'Oct', users: 55 }, { month: 'Nov', users: 78 },
  { month: 'Dec', users: 95 }, { month: 'Jan', users: 120 }, { month: 'Feb', users: 138 }, { month: 'Mar', users: 150 },
];

export const weeklyUserData = [
  { day: 'Mon', users: 8 }, { day: 'Tue', users: 12 }, { day: 'Wed', users: 10 },
  { day: 'Thu', users: 15 }, { day: 'Fri', users: 18 }, { day: 'Sat', users: 22 }, { day: 'Sun', users: 14 },
];

export const avgScoreData = [
  { test: 'IELTS', avgScore: 7.1 }, { test: 'TOEFL', avgScore: 88 }, { test: 'PTE', avgScore: 71 },
];

export const subscriptionPieData = [
  { name: 'Free', value: 70, color: '#6C757D' },
  { name: 'Basic', value: 50, color: '#007BFF' },
  { name: 'Premium', value: 30, color: '#28A745' },
];

export const revenueData = [
  { month: 'Oct', revenue: 28000 }, { month: 'Nov', revenue: 34000 }, { month: 'Dec', revenue: 41000 },
  { month: 'Jan', revenue: 45000 }, { month: 'Feb', revenue: 50000 }, { month: 'Mar', revenue: 58000 },
];

// ─── AI Usage ─────────────────────────────────────────────────────────────────
export const dummyAILogs = [
  { id: 'AI001', type: 'Essay Feedback', user: 'ahmed.raza@example.com', timestamp: '2026-03-05 10:32', result: 'Band 7.5 – Good coherence, minor grammar issues...', status: 'success', cost: 0.02 },
  { id: 'AI002', type: 'Audio Transcription', user: 'fatima.noor@example.com', timestamp: '2026-03-05 09:15', result: 'Transcription complete – 98% accuracy.', status: 'success', cost: 0.05 },
  { id: 'AI003', type: 'Question Generation', user: 'System', timestamp: '2026-03-04 14:20', result: '10 MCQ questions generated for IELTS Reading Mock #3.', status: 'success', cost: 0.03 },
  { id: 'AI004', type: 'Content Moderation', user: 'System', timestamp: '2026-03-04 08:00', result: '2 posts flagged as toxic/spam.', status: 'success', cost: 0.01 },
  { id: 'AI005', type: 'Essay Feedback', user: 'bilal.s@example.com', timestamp: '2026-03-03 16:45', result: 'Band 8.0 – Excellent argument structure...', status: 'success', cost: 0.02 },
  { id: 'AI006', type: 'Audio Transcription', user: 'zaid.h@example.com', timestamp: '2026-03-03 11:00', result: 'Error: Audio quality too low.', status: 'error', cost: 0.00 },
];
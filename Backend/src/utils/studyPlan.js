import { analyzeWeakness } from './weaknessAnalyzer.js';
import pool from '../config/db.js';

export const generateStudyPlan = async (userId, durationDays, targetBand) => {
    const weakness = await analyzeWeakness(userId);
    const userRes = await pool.query(
        `SELECT subscription FROM users WHERE id = $1`,
        [userId]
    );
    const subscription = userRes.rows[0]?.subscription || 'free';
    
    const allowedSubscriptions = ['free'];
    if (subscription === 'basic' || subscription === 'premium') allowedSubscriptions.push('basic');
    if (subscription === 'premium') allowedSubscriptions.push('premium');
    
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(startDate.getDate() + durationDays - 1);
    
    const planItems = [];
    const weakSections = weakness.weakSections.length > 0 
        ? weakness.weakSections 
        : ['Reading', 'Listening', 'Writing', 'Speaking'];
    
    for (let day = 1; day <= durationDays; day++) {
        const dailyItems = [];
        const sectionIndex = (day - 1) % weakSections.length;
        const focusSection = weakSections[sectionIndex];
        
        const morningLesson = await pool.query(
            `SELECT id, title, estimated_minutes
             FROM lessons
             WHERE status = 'published'
             AND section = $1
             AND min_subscription = ANY($2)
             AND target_band <= $3
             ORDER BY RANDOM()
             LIMIT 1`,
            [focusSection, allowedSubscriptions, targetBand]
        );
        
        if (morningLesson.rows.length > 0) {
            dailyItems.push({
                day_number: day,
                item_type: 'lesson',
                item_id: morningLesson.rows[0].id,
                title: morningLesson.rows[0].title,
                estimated_minutes: morningLesson.rows[0].estimated_minutes || 30
            });
        }
        
        const afternoonPractice = await pool.query(
            `SELECT q.id, q.question_text, ts.section_name
             FROM questions q
             JOIN test_sections ts ON q.section_id = ts.id
             WHERE ts.section_name = $1
             AND q.correct_answer IS NOT NULL
             ORDER BY RANDOM()
             LIMIT 5`,
            [focusSection]
        );
        
        if (afternoonPractice.rows.length > 0) {
            dailyItems.push({
                day_number: day,
                item_type: 'practice',
                item_id: afternoonPractice.rows[0].id,
                title: `${focusSection} Practice (${afternoonPractice.rows.length} questions)`,
                estimated_minutes: 45
            });
        }
        
        if (day % 3 === 0) {
            const mockTest = await pool.query(
                `SELECT id, title
                 FROM tests
                 WHERE exam_type = 'IELTS'
                 AND is_published = true
                 ORDER BY RANDOM()
                 LIMIT 1`
            );
            if (mockTest.rows.length > 0) {
                dailyItems.push({
                    day_number: day,
                    item_type: 'mock_test',
                    item_id: mockTest.rows[0].id,
                    title: `Mock Test: ${mockTest.rows[0].title}`,
                    estimated_minutes: 60
                });
            }
        }
        
        planItems.push(...dailyItems);
    }
    
    return {
        title: `${durationDays}-Day IELTS Band ${targetBand} Plan`,
        target_band: targetBand,
        start_date: startDate.toISOString().split('T')[0],
        end_date: endDate.toISOString().split('T')[0],
        items: planItems
    };
};
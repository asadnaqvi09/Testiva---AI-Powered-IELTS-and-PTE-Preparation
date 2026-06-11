import { analyzeWeakness } from './weaknessAnalyzer.js';
import pool from '../config/db.js';

export const generateRecommendations = async (userId) => {
    const weakness = await analyzeWeakness(userId);
    const userRes = await pool.query('SELECT subscription FROM users WHERE id = $1', [userId]);
    const sub = userRes.rows[0]?.subscription || 'free';
    
    const allowed = ['free'];
    if (['basic', 'premium'].includes(sub)) allowed.push('basic');
    if (sub === 'premium') allowed.push('premium');
    
    const targetBand = Math.min(weakness.averageBand + 1.5, 9.0);
    const weakAreas = weakness.sectionAccuracy.filter(s => s.accuracy < 60);
    
    const lessons = await Promise.all(weakAreas.map(async (section) => {
        const res = await pool.query(
            `SELECT id, title, section FROM lessons 
             WHERE status = 'published' AND section = $1 
             AND min_subscription = ANY($2) AND target_band <= $3 
             LIMIT 2`, 
            [section.section_name, allowed, targetBand]
        );
        return res.rows;
    }));

    return {
        weakAreas,
        suggestedLessons: lessons.flat(),
        targetBand
    };
};
import { writingRubric } from '../rubrics/writing.rubric.js';

export const writingPrompt = (taskType, question, studentResponse) => {
    return `
    Act as a highly experienced IELTS Examiner.
    Evaluate the following ${taskType} response based on official IELTS Assessment Criteria.
    CRITERIA & GUIDELINES:
    ${writingRubric.criteria.map(c => `- ${c}`).join('\n')}
    SCORING LOGIC:
    - Base the scores on these descriptors: ${JSON.stringify(writingRubric.bandDescriptors)}
    - Scores must be in 0.5 increments (e.g., 6.0, 6.5).
    CONTEXT:
    Question: "${question}"
    Student Response: "${studentResponse}"
    OUTPUT INSTRUCTIONS:
    Return ONLY a valid JSON object. Do not include any introductory or concluding text.
    REQUIRED JSON STRUCTURE:
    {
      "overall_band_score": 0.0,
      "task_response_score": 0.0,
      "coherence_cohesion_score": 0.0,
      "lexical_resource_score": 0.0,
      "grammatical_range_score": 0.0,
      "detailed_analysis": {
        "mistakes": ["specific grammar or vocabulary errors found"],
        "corrections": ["rewritten versions of the sentences containing those errors"]
      },
      "improvement_suggestions": "A concise actionable guide to move to the next 0.5 band."
    }
    `;
}
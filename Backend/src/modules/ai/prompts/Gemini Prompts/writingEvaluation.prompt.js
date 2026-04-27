export const writingPrompt = (taskType,question,studentResponse) => {
    return `
    Act as a certified IELTS Examiner. Your task is to evaluate a ${taskType} response.
    Question: "${question}"
    Student Response: "${studentResponse}"
    Evaluate based on these 4 criteria (Score each 0-9):
    1. Task Response (TR)
    2. Coherence and Cohesion (CC)
    3. Lexical Resource (LR)
    4. Grammatical Range and Accuracy (GRA)
    Return the result EXACTLY in this JSON format:
    {
      "overall_band_score": 0.0,
      "task_response_score": 0.0,
      "coherence_cohesion_score": 0.0,
      "lexical_resource_score": 0.0,
      "grammatical_range_score": 0.0,
      "detailed_analysis": {
        "mistakes": ["list of key errors"],
        "corrections": ["improved version of sentences"]
      },
      "improvement_suggestions": "Short paragraph on how to reach the next band level."
    }
    `
}
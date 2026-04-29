export const writingRubric = {
    criteria: [
        "Task Response: How well the candidate addresses the task.",
        "Coherence and Cohesion: The clarity and fluency of the message.",
        "Lexical Resource: The range and accuracy of vocabulary used.",
        "Grammatical Range and Accuracy: The range and accuracy of the grammar used."
    ],
    bandDescriptors: {
        9: "Expert user with full operational command of the language.",
        7: "Good user with occasional inaccuracies but generally handles complex language well.",
        5: "Modest user with partial command; likely to make many mistakes.",
        1: "Non-user with no ability to use the language."
    },
    instructions: "Evaluate the text based on these 4 pillars. Provide a score from 0 to 9.0 in 0.5 increments."
};
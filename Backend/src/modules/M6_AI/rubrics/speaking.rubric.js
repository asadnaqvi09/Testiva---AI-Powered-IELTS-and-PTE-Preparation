export const speakingRubric = {
    exam_type: "IELTS/PTE",
    pillars: {
        fluency_coherence: {
            label: "Fluency and Coherence",
            focus: ["Speech continuity", "Self-correction", "Hesitation frequency", "Logical development"]
        },
        lexical_resource: {
            label: "Lexical Resource",
            focus: ["Vocabulary flexibility", "Idiomatic usage", "Paraphrasing ability"]
        },
        grammar_accuracy: {
            label: "Grammatical Range and Accuracy",
            focus: ["Complex structures", "Tense consistency", "Error density"]
        },
        pronunciation: {
            label: "Pronunciation",
            focus: ["Intonation", "Individual sounds clarity", "Word/Sentence stress", "Ease of being understood"]
        }
    },
    negative_markers: [
        "Long pauses (5+ seconds)", 
        "Repetition of same filler words (um, uh, like)", 
        "Short, undeveloped answers"
    ],
    scoring_system: {
        min: 0,
        max: 9.0,
        step: 0.5
    }
};
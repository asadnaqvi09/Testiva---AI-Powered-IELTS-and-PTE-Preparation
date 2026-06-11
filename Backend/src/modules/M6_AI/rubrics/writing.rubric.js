export const writingRubric = {
    exam_type: "IELTS/PTE",
    pillars: {
        task_response: {
            label: "Task Response",
            description: "How well the candidate addresses the task and develops ideas."
        },
        coherence_cohesion: {
            label: "Coherence and Cohesion",
            description: "Logical organization, paragraphing, and use of cohesive devices."
        },
        lexical_resource: {
            label: "Lexical Resource",
            description: "Range, precision, and accuracy of vocabulary (collocations, spelling)."
        },
        grammar_accuracy: {
            label: "Grammatical Range and Accuracy",
            description: "Sentence structures, punctuation, and frequency of error-free sentences."
        }
    },
    scoring_system: {
        min: 0,
        max: 9.0,
        step: 0.5,
        logic: "Average of all 4 pillars, rounded to the nearest 0.5 increment."
    },
    band_descriptors: {
        9: "Expert: Full operational command, appropriate, accurate, and fluent.",
        7: "Good: Generally handles complex language well, though with occasional inaccuracies.",
        5: "Modest: Partial command, conveys overall meaning but many grammatical mistakes.",
        3: "Extremely Limited: Great difficulty in understanding and expression."
    }
};
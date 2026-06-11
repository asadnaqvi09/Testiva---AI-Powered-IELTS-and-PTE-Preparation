export const calculateIELTSBand = (correctAnswers, totalQuestions = 40) => {
    if (!correctAnswers || totalQuestions === 0) return 0.0;
    const rawToBand = [
        { min: 39, band: 9.0 }, { min: 37, band: 8.5 }, { min: 35, band: 8.0 },
        { min: 32, band: 7.5 }, { min: 30, band: 7.0 }, { min: 26, band: 6.5 },
        { min: 23, band: 6.0 }, { min: 18, band: 5.5 }, { min: 15, band: 5.0 },
        { min: 12, band: 4.5 }, { min: 9,  band: 4.0 }, { min: 6,  band: 3.5 },
        { min: 4,  band: 3.0 }, { min: 0,  band: 0.0 }
    ];
    const match = rawToBand.find(s => correctAnswers >= s.min);
    return match ? match.band : 0.0;
};

export const roundIELTSOverall = (averageScore) => {
    const fraction = averageScore - Math.floor(averageScore);
    if (fraction < 0.25) return Math.floor(averageScore);
    if (fraction < 0.75) return Math.floor(averageScore) + 0.5;
    return Math.ceil(averageScore);
};

export const calculatePTEScore = (rawScore, maxScore) => {
    if (!rawScore || maxScore === 0) return 10;
    const scaledScore = Math.round((rawScore / maxScore) * 80) + 10;
    return Math.min(90, Math.max(10, scaledScore));
};
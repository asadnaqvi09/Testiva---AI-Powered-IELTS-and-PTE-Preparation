export const calculateIELTSBand = (rawScore, maxScore) => {
    const percentage = (rawScore / maxScore) * 100;
    if (percentage >= 90) return 9.0;
    if (percentage >= 80) return 8.0;
    if (percentage >= 70) return 7.0;
    if (percentage >= 60) return 6.0;
    if (percentage >= 50) return 5.0;
    if (percentage >= 40) return 4.0;
    if (percentage >= 30) return 3.0;
    if (percentage >= 20) return 2.0;
    if (percentage >= 10) return 1.0;
    return 0.0;
};

export const calculatePTEScore = (rawScore, maxScore) => {
    return Math.round((rawScore / maxScore) * 90);
};

export const calculateSectionScore = (correctCount, totalQuestions, examType) => {
    if (examType === 'IELTS') {
        return calculateIELTSBand(correctCount, totalQuestions);
    }
    if (examType === 'PTE') {
        return calculatePTEScore(correctCount, totalQuestions);
    }
    return 0;
};
export const calculateIELTSBand = (rawScore, maxScore) => {
    const percentage = (rawScore / maxScore) * 100;
    const scores = [
        { min: 90, band: 9.0 }, { min: 80, band: 8.0 },
        { min: 70, band: 7.0 }, { min: 60, band: 6.0 },
        { min: 50, band: 5.0 }, { min: 40, band: 4.0 },
        { min: 30, band: 3.0 }, { min: 20, band: 2.0 },
        { min: 10, band: 1.0 }
    ];
    const match = scores.find(s => percentage >= s.min);
    return match ? match.band : 0.0;
};

export const calculatePTEScore = (rawScore, maxScore) => Math.round((rawScore / maxScore) * 90);
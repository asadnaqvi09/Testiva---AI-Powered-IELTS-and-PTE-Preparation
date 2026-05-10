export const processWritingResponse = (studentResponse) => {
    if (!studentResponse || typeof studentResponse !== 'string') {
        throw new Error("Invalid response: Input must be a string.");
    }
    const cleanResponse = studentResponse.trim().replace(/\s+/g, ' ');
    const wordCount = cleanResponse.split(/\s+/).filter(word => word.length > 0).length;
    const isTooShort = wordCount < 10;
    return {
        processedText: cleanResponse,
        wordCount,
        isTooShort,
        processedAt: new Date()
    };
};
export const validatePasswordMatch = (password,confirm_password) => {
    if (password !== confirm_password) {
        throw new Error('Password did not match please provide correct password')
    }
}
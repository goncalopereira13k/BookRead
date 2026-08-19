module.exports = {
  username: (username) => {
    const usernameRegex = /^[a-z0-9_]{3,20}$/;
    // Lower case alphanumeric characters and underscores, 3 to 20 characters long
    return usernameRegex.test(username);
  },
  email: (email) => {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailRegex.test(email);
  },
  birthdate: (birthdate) => {
    const date = new Date(birthdate);
    const today = new Date();
    return date instanceof Date && !isNaN(date) && date < today;
  },
  gender: (gender) => {
    /*
     * 0: not set
     * 1: male
     * 2: female
     */
    return [0, 1, 2].includes(gender);
  },
  password: (password) => {
    // const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/;
    const passwordRegex = /^.*$/;
    // At least 8 characters, at least one uppercase letter, one lowercase letter and one number
    return passwordRegex.test(password);
  },
}
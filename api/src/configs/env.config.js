const dotenv = require('dotenv');
dotenv.config();
// Load environment variables from .env file
const env = process.env || 'development';

module.exports = env;

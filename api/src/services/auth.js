const jwt = require('jsonwebtoken');
const env = require('../configs/env.config');

module.exports = {
  // Generate a JWT token for the user
  generateToken: (user) => {
    return jwt.sign({ id: user.id, username: user.username }, env.JWT_SECRET, { expiresIn: '7d' });
  }
}
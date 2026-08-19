const jwt = require('jsonwebtoken');
const env = require('../configs/env.config.js');
const db = require('../models/index.js');
const User = db.user;

module.exports = {
  authMiddleware: async (req, res, next) => {
    const authHeader = req.headers['authorization']
    const token = authHeader && authHeader.split(' ')[1]

    if (token == null) return res.sendStatus(401);

    jwt.verify(token, env.JWT_SECRET, async (err, data) => {
      if (err) return res.sendStatus(403);

      const user = await User.findByPk(data.id);

      if (!user) {
        return res.sendStatus(403);
      }

      if (user.isDeleted) {
        return res.status(403).json({ message: 'User is deleted' });
      }

      req.user = user;

      next();
    });
  },
  hasAdmin: async (req, res, next) => {
    const user = req.user;
    if (!user.role || user.role !== 'admin') {
      return res.sendStatus(403);
    }

    next();
  }
}
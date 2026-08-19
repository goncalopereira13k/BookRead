const statsController = require('../controllers/stats')
const {authMiddleware } = require('../middlewares/auth')
const router = require('express').Router()

router.use(authMiddleware)

// Streak
router.get('/streak', statsController.getStreak)

module.exports = router
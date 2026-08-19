const goalController = require('../controllers/goal.js')
const { authMiddleware } = require('../middlewares/auth.js')
const router = require('express').Router()

router.use(authMiddleware)

router.post('/daily', goalController.createDailyGoal)
router.get('/daily', goalController.getDailyGoal)
router.post('/yearly', goalController.createYearlyGoal)
router.get('/yearly', goalController.getYearlyGoal)

module.exports = router
const settingsController = require('../controllers/settings.js')
const { authMiddleware } = require('../middlewares/auth.js')
const router = require('express').Router()

router.use(authMiddleware)

router.get('/', settingsController.getSettings)
router.put('/', settingsController.updateSettings)

module.exports = router
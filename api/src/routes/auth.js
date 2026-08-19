const authController = require('../controllers/auth.js')
const { hasAdmin } = require('../middlewares/auth.js');
const router = require('express').Router()

router.post('/login', authController.login)
router.post('/register', authController.register)

router.post('/loginDashboard', authController.loginAdmin);

module.exports = router
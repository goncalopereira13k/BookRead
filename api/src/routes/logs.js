const logsController = require('../controllers/logs.js')
const { authMiddleware, hasAdmin } = require('../middlewares/auth.js');
const router = require('express').Router()

router.use(authMiddleware);

router.get('/get10', [hasAdmin], logsController.getLastLogs)
router.get('/getByUser', [hasAdmin], logsController.getUserLogs)

module.exports = router
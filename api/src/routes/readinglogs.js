const readingLogController = require('../controllers/readinglog.js')
const { authMiddleware, hasAdmin } = require("../middlewares/auth")
const router = require('express').Router()

router.use(authMiddleware);

router.get('/', readingLogController.getReadingLogsByBookStatus);
router.get('/countPages', readingLogController.countReadedPagesByDate)
router.post('/', readingLogController.createReadingLog);
router.delete('/', readingLogController.deleteReadingLog);

// Backoffice
router.get('/countAll', [hasAdmin], readingLogController.countAllReadingLogsByDate);

module.exports = router
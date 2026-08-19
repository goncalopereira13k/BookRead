const bookStatusController = require('../controllers/bookstatus.js')
const { authMiddleware } = require('../middlewares/auth.js')
const booknoteController = require('../controllers/booknotes.js')
const router = require('express').Router()

router.use(authMiddleware)

// Reading books
router.get('/all', bookStatusController.getAll)
router.get('/wanted', bookStatusController.getWanted)
router.get('/reading', bookStatusController.getReading)
router.get('/readed', bookStatusController.getReaded)
router.get('/archived', bookStatusController.getArchived)

router.post('/wanted', bookStatusController.setWanted)
router.post('/reading', bookStatusController.setReading)
router.post('/readed', bookStatusController.setReaded)
router.post('/archived', bookStatusController.setArchived)
router.post('/rate', bookStatusController.setRate)

router.delete('/wanted', bookStatusController.deleteWanted)

// Book notes
router.get('/notes', booknoteController.getBookNotes)
router.post('/notes', booknoteController.createBookNote)
router.put('/notes', booknoteController.updateBookNote)
router.delete('/notes', booknoteController.deleteBookNote)
router.get('/notes/count', booknoteController.countNotesByDate);


router.get('/countReaded', bookStatusController.countReadedBooksByYear)

module.exports = router
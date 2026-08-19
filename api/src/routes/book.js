const bookController = require('../controllers/book.js')
const { authMiddleware } = require('../middlewares/auth.js')
const router = require('express').Router()

router.use(authMiddleware)

router.post('/', bookController.createBook)
router.get('/', bookController.getById)


module.exports = router
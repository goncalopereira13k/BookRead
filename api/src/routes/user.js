const userController = require('../controllers/user.js');
const { authMiddleware, hasAdmin } = require('../middlewares/auth.js');
const router = require('express').Router();

router.use(authMiddleware);

// User routes
router.get('/', userController.getUser);
router.put('/', userController.updateUser);
router.put('/changePassword', userController.changePassword);
router.get('/all', [hasAdmin], userController.getAllUsers);
router.put('/updateById', [hasAdmin], userController.updateUserById);
router.delete('/deleteById', [hasAdmin], userController.deleteUserById);

module.exports = router;
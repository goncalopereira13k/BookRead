const express = require('express');
const cors = require('cors');

const app = express()

app.use(cors({
  origin: 'http://localhost:3001'
}));

const appRoutes = require('./routes/app.js')
const authRoutes = require('./routes/auth.js')
const settingsRoutes = require('./routes/settings.js')
const goalRoutes = require('./routes/goal.js')
const bookStatusRoutes = require('./routes/books.js')
const readinglogRoutes = require('./routes/readinglogs.js')
const userRoutes = require('./routes/user.js')
const bookRoutes = require('./routes/book.js')
const statsRoutes = require('./routes/stats.js')
const logsRoutes = require('./routes/logs.js')

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Set routes
app.use('/', appRoutes)
app.use('/auth', authRoutes)
app.use('/settings', settingsRoutes)
app.use('/goal', goalRoutes)
app.use('/books', bookStatusRoutes)
app.use('/readinglog', readinglogRoutes)
app.use('/user', userRoutes)
app.use('/book', bookRoutes)
app.use('/stats', statsRoutes);
app.use('/logs', logsRoutes)

const db = require('./models/index.js')

// Only sync database if not in test environment
// Tests handle their own DB sync in jest.setup.js
if (process.env.NODE_ENV !== 'test') {
  db.sequelize.sync({ force: false })
    .then(() => {
      console.log('Synced db.')
    }).catch((err) => {
      console.log('Failed to sync db: ' + err.message)
    })
}

module.exports = app;
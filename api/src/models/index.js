const dbConfig = require('../configs/db.config.js')

const Sequelize = require('sequelize')
const isTestEnvironment = process.env.NODE_ENV === 'test'
const sequelize = isTestEnvironment ? new Sequelize(
  {
    dialect: dbConfig.dialect,
    storage: ':memory:',
    logging: dbConfig.logging || (() => { }), // Use config logging or disable
  }
) : new Sequelize(dbConfig.DB, dbConfig.USER, dbConfig.PASSWORD, {
  host: dbConfig.HOST,
  dialect: dbConfig.dialect,
  logging: dbConfig.logging,
  pool: {
    max: dbConfig.pool.max,
    min: dbConfig.pool.min,
    acquire: dbConfig.pool.acquire,
    idle: dbConfig.pool.idle,
  },
});

const db = {}
db.Sequelize = Sequelize
db.sequelize = sequelize

db.book = require('./book.model.js')(sequelize, Sequelize)
db.user = require('./user.model.js')(sequelize, Sequelize)
db.log = require('./log.model.js')(sequelize, Sequelize)
db.goal = require('./goal.model.js')(sequelize, Sequelize)
db.settings = require('./settings.model.js')(sequelize, Sequelize)
db.bookstatus = require('./bookstatus.model.js')(sequelize, Sequelize)
db.readinglog = require('./readinglog.model.js')(sequelize, Sequelize)
db.booknote = require('./booknote.model.js')(sequelize, Sequelize)

/*
 * Associations
 */
// User
db.user.hasMany(db.booknote, {
  foreignKey: 'userId',
  as: 'booknotes',
})
db.user.hasOne(db.settings, {
  foreignKey: 'userId',
  as: 'settings',
})
db.user.hasMany(db.log, {
  foreignKey: 'userId',
  as: 'logs',
})
db.user.hasMany(db.bookstatus, {
  foreignKey: 'userId',
  as: 'bookstatus',
})
db.user.hasMany(db.readinglog, {
  foreignKey: 'userId',
  as: 'readinglogs',
})
db.user.hasMany(db.goal, {
  foreignKey: 'userId',
  as: 'goals',
})

// Settings
db.settings.belongsTo(db.user, {
  foreignKey: 'userId',
  as: 'user',
})

// Goal
db.goal.belongsTo(db.user, {
  foreignKey: 'userId',
  as: 'user',
})

// BookStatus
db.bookstatus.belongsTo(db.user, {
  foreignKey: 'userId',
  as: 'user',
})
db.bookstatus.belongsTo(db.book, {
  foreignKey: 'bookId',
  as: 'book',
})
db.bookstatus.hasMany(db.booknote, {
  foreignKey: 'bStatusId',
  as: 'booknotes',
})
db.bookstatus.hasMany(db.readinglog, {
  foreignKey: 'bStatusId',
  as: 'readinglogs',
})

// ReadingLog
db.readinglog.belongsTo(db.bookstatus, {
  foreignKey: 'bStatusId',
  as: 'bookstatus',
});
db.readinglog.belongsTo(db.user, {
  foreignKey: 'userId',
  as: 'user',
})

// Log
db.log.belongsTo(db.user, {
  foreignKey: 'userId',
  as: 'user',
})

// Book
db.book.hasMany(db.bookstatus, {
  foreignKey: 'bookId',
  as: 'bookstatus',
})
db.book.hasMany(db.booknote, {
  foreignKey: 'bookId',
  as: 'booknotes',
})

// BookNote
db.booknote.belongsTo(db.user, {
  foreignKey: 'userId',
  as: 'user',
})
db.booknote.belongsTo(db.bookstatus, {
  foreignKey: 'bStatusId',
  as: 'bookstatus',
})

module.exports = db

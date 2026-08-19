const validate = require('../helpers/validate');

module.exports = (sequelize, Sequelize) => {
  const BookStatus = sequelize.define('book_statuses', {
    id: {
      type: Sequelize.BIGINT,
      primaryKey: true,
      autoIncrement: true,
    },
    bookId: {
      type: Sequelize.BIGINT,
      allowNull: false,
      references: {
        model: 'books',
        key: 'id',
      },
      onDelete: 'CASCADE',
    },
    userId: {
      type: Sequelize.BIGINT,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id',
      },
      onDelete: 'CASCADE',
    },

    /**
     * 0 - Wanted
     * 1 - Reading
     * 2 - Readed
     * 3 - Archived
     */
    status: {
      type: Sequelize.INTEGER,
      allowNull: false,
      validate: {
        isIn: {
          args: [
            [
              BookStatusType.WANTED,
              BookStatusType.READING,
              BookStatusType.READED,
              BookStatusType.ARCHIVED,
            ],
          ],
          msg: 'Invalid status',
        },
      },
      defaultValue: BookStatusType.WANTED,
    },
    startDate: {
      type: Sequelize.DATE,
      allowNull: true,
    },
    endDate: {
      type: Sequelize.DATE,
      allowNull: true,
    },
    rate: {
      type: Sequelize.INTEGER,
      allowNull: true,
    }
  }, {
    timezone: '+00:00',
    freezeTableName: true,
    indexes: [
      { fields: ['userId'] },
      { fields: ['status'] },
      { fields: ['bookId'] },
      { fields: ['userId', 'status'] },
    ]
  });
  return BookStatus;
}

const BookStatusType = {
  WANTED: 0,
  READING: 1,
  READED: 2,
  ARCHIVED: 3,
}

module.exports.BookStatusType = BookStatusType;

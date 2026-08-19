module.exports = (sequelize, Sequelize) => {
  const BookNote = sequelize.define('book_notes', {
    id: {
      type: Sequelize.BIGINT,
      autoIncrement: true,
      primaryKey: true,
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
    page: {
      type: Sequelize.INTEGER,
    },
    content: {
      type: Sequelize.TEXT,
      allowNull: false,
      validate: {
        notEmpty: true,
      },
    },
  }, {
    timezone: '+00:00',
    freezeTableName: true,
    indexes: [
      { fields: ['userId', 'bookId'] },
    ]
  });

  return BookNote;
}
module.exports = (sequelize, Sequelize) => {
  const ReadingLog = sequelize.define('reading_logs', {
    id: {
      type: Sequelize.BIGINT,
      primaryKey: true,
      autoIncrement: true,
    },
    bStatusId: {
      type: Sequelize.BIGINT,
      allowNull: false,
      references: {
        model: 'book_statuses',
        key: 'id',
        onDelete: 'CASCADE',
      },
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
    duration: { // In seconds
      type: Sequelize.INTEGER,
      allowNull: true,
      validate: {
        min: 0,
      },
    },
    pagesReaded: {
      type: Sequelize.INTEGER,
      allowNull: false,
      validate: {
        min: 0,
      },
    },
  }, {
    timezone: '+00:00',
    freezeTableName: true,
    indexes: [
      { fields: ['userId', 'createdAt'] }
    ]
  });

  return ReadingLog;
}
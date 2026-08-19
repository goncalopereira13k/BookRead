module.exports = (sequelize, Sequelize) => {
  const Settings = sequelize.define('settings', {
    userId: {
      type: Sequelize.BIGINT,
      primaryKey: true,
      references: {
        model: 'users',
        key: 'id',
      },
      onDelete: 'CASCADE',
    },
    notifDaily: {
      type: Sequelize.BOOLEAN,
      allowNull: false,
    },
    notifGoal: {
      type: Sequelize.BOOLEAN,
      allowNull: false,
    },
  }, {
    freezeTableName: true,
  });

  return Settings;
}

const DefaultSettings = {
  notifDaily: true,
  notifGoal: true,
};

module.exports.DefaultSettings = DefaultSettings;

module.exports = (sequelize, Sequelize) => {
  const Log = sequelize.define('logs', {
    id: {
      type: Sequelize.BIGINT,
      primaryKey: true,
      autoIncrement: true,
    },
    userId: {
      type: Sequelize.BIGINT,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      },
      onDelete: 'CASCADE',
    },
    tmstamp: {
      type: Sequelize.DATE,
      allowNull: false,
    },
    action: {
      type: Sequelize.INTEGER,
      allowNull: false,
      validate: {
        isIn: {
          args: [
            [
              LogAction.REGISTER,
              LogAction.LOGIN,
              LogAction.PROFILE_UPDATE,
              LogAction.PROFILE_DELETE,
              LogAction.CHANGE_PASSWORD,
              LogAction.ADMIN_PROFILE_UPDATE,
            ]
          ],
          msg: 'Invalid action',
        }
      }
    },
    ipAddress: {
      type: Sequelize.CHAR(45),
      validate: {
        isIP: true,
      },
    },
  }, {
    timezone: '+00:00',
    timestamps: false,
    freezeTableName: true,
  });

  return Log;
}

const LogAction = {
  REGISTER: 0,
  LOGIN: 1,
  PROFILE_UPDATE: 2,
  PROFILE_DELETE: 3,
  CHANGE_PASSWORD: 4,
  ADMIN_PROFILE_UPDATE: 5,
};

module.exports.LogAction = LogAction;
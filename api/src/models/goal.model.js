module.exports = (sequelize, Sequelize) => {
  const Goal = sequelize.define('goals', {
    userId: {
      type: Sequelize.BIGINT,
      primaryKey: true,
      allowNull: false,
      references: {
        model: 'users',
        key: 'id'
      },
      onDelete: 'CASCADE',
    },
    /**
     * 0 - Daily
     * 1 - Yearly
     */
    type: {
      type: Sequelize.INTEGER,
      primaryKey: true,
      allowNull: false,
      validate: {
        isIn: {
          args: [
            [
              GoalType.DAILY,
              GoalType.YEARLY,
            ]
          ],
          msg: 'Invalid type',
        }
      }
    },
    value: {
      type: Sequelize.INTEGER,
      allowNull: false,
      validate: {
        isInt: true,
        min: 1,
      },
    }
  }, {
    freezeTableName: true,
  });

  return Goal;
}

const GoalType = {
  DAILY: 0,
  YEARLY: 1,
}

module.exports.GoalType = GoalType;

const DefaultGoals = {
  DAILY: 5,
  YEARLY: 5,
};

module.exports.DefaultGoals = DefaultGoals;

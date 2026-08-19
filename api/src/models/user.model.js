const validate = require('../helpers/validate');

module.exports = (sequelize, Sequelize) => {
  const User = sequelize.define('users', {
    id: {
      type: Sequelize.BIGINT,
      primaryKey: true,
      autoIncrement: true,
    },
    username: {
      type: Sequelize.STRING,
      allowNull: false,
      unique: true,
      validate: {
        notEmpty: true,
      },
    },
    email: {
      type: Sequelize.STRING,
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
        notEmpty: true,
      },
    },
    passhash: {
      type: Sequelize.STRING(255),
      allowNull: false,
      validate: {
        notEmpty: true,
      },
    },
    birthdate: {
      type: Sequelize.DATE,
      allowNull: false,
      validate: {
        isDate: true,
        notEmpty: true,
        isBefore: new Date().toString(),
      },
    },
    gender: {
      type: Sequelize.SMALLINT,
      allowNull: false,
      defaultValue: 0,
    },
    avatar: {
      type: Sequelize.STRING,
    },
    isVerified: {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    role: {
      type: Sequelize.ENUM(
        'admin'
      ),
      allowNull: true,
    },
    deletedAt: {
      type: Sequelize.DATE,
      allowNull: true,
      defaultValue: null,
      validate: {
        isDate: true,
      },
    },
  }, {
    validate: {
      birthdateCheck() {
        if (this.birthdate >= new Date()) {
          throw new Error('Birthdate must be in the past.');
        }
      },
    },
    freezeTableName: true,
    indexes: [
      { unique: true, fields: ['username'] },
      { unique: true, fields: ['email'] },
      { fields: ['deletedAt'] },
      { fields: ['email', 'deletedAt'] },
      { fields: ['username', 'deletedAt'] },
    ],
  });

  return User;
}

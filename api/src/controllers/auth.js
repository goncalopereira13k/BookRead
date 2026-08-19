const db = require('../models');
const { Op } = require('sequelize')
const bcrypt = require('bcrypt');
const User = db.user;
const Goal = db.goal;
const Settings = db.settings;
const Log = db.log;
const authService = require('../services/auth');
const validate = require('../helpers/validate');
const { GoalType } = require('../models/goal.model');
const { DefaultGoals } = require('../models/goal.model');
const { DefaultSettings } = require('../models/settings.model');
const { LogAction } = require('../models/log.model');

module.exports = {
  login: async (req, res) => {
    try {
      var email = req.body.email;
      var password = req.body.password;

      /*
       * Validate the inputs
       */
      // Check for required fields
      if (!email || !password) {
        return res.status(400).json({ message: 'Email e senha são obrigatórios' });
      }
      // Check for valid email format
      if (!validate.email(email)) {
        return res.status(400).json({ message: 'Formato de email inválido' });
      }
      // Check for valid password
      let users = [];

      try {
        users = await User.findAll({ where: { email: email, deletedAt: null } })
      } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Erro de base de dados' });
      }

      if (users.length === 0) {
        return res.status(400).json({ message: 'Email ou senha inválidos' });
      }
      // Check password
      const isValidPassword = bcrypt.compareSync(password, users[0].passhash);
      if (!isValidPassword) {
        return res.status(400).json({ message: 'Email ou senha inválidos' });
      }

      const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress
      await users[0].createLog({
        tmstamp: Date.now(),
        action: LogAction.LOGIN,
        ipAddress: ipAddress,
      });

      return res.status(200).json({
        token: authService.generateToken(users[0]),
        user: {
          id: users[0].id,
          username: users[0].username,
          email: users[0].email,
          birthdate: users[0].birthdate,
          gender: users[0].gender,
          avatar: users[0].avatar,
          createdAt: users[0].createdAt,
        },
        goals: await users[0].getGoals(),
        settings: await users[0].getSettings(),
      });

    }
    catch (err) {
      res.status(500).send(err)
    }
  },
  loginAdmin: async (req, res) => {
    try {
      var email = req.body.email;
      var password = req.body.password;

      /*
       * Validate the inputs
       */
      // Check for required fields
      if (email === null || password === null) {
        return res.status(400).json({ message: 'Email e senha são obrigatórios' });
      }
      // Check for valid email format
      if (!validate.email(email)) {
        return res.status(400).json({ message: 'Formato de email inválido' });
      }
      // Check for valid password
      let users = [];

      try {
        users = await User.findAll({ where: { email: email, deletedAt: null, role: 'admin' } })
      } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Erro de base de dados' });
      }

      if (users.length === 0) {
        return res.status(400).json({ message: 'Email ou senha inválidos' });
      }
      // Check password
      const isValidPassword = bcrypt.compareSync(password, users[0].passhash);
      if (!isValidPassword) {
        return res.status(400).json({ message: 'Email ou senha inválidos' });
      }

      const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress
      await users[0].createLog({
        tmstamp: Date.now(),
        action: LogAction.LOGIN,
        ipAddress: ipAddress,
      });

      return res.json({
        token: authService.generateToken(users[0]),
        user: {
          id: users[0].id,
          username: users[0].username,
          email: users[0].email,
          birthdate: users[0].birthdate,
          gender: users[0].gender,
          avatar: users[0].avatar,
          createdAt: users[0].createdAt,
        },
        goals: await users[0].getGoals(),
        settings: await users[0].getSettings(),
      });

    }
    catch (err) {
      res.status(500).send(err)
    }
  },
  // Sign up a new user
  register: async (req, res) => {
    try {
      var username = req.body.username;
      var email = req.body.email;
      var birthdate = req.body.birthdate;
      var gender = req.body.gender;
      var password = req.body.password;

      /*
       * Validate the inputs
       */
      // Check for required fields
      if (!username || !email || !birthdate || gender === null || gender === undefined || !password) {
        return res.status(400).json({ message: 'Nome de utilizador, email, data de nascimento, género e senha são obrigatórios' });
      }
      // Check for valid username format
      if (!validate.username(username)) {
        return res.status(400).json({ message: 'Formato de nome de utilizador inválido' });
      }
      // Check for valid email format
      if (!validate.email(email)) {
        return res.status(400).json({ message: 'Formato de email inválido' });
      }
      // Check for valid birthdate format
      if (!validate.birthdate(birthdate)) {
        return res.status(400).json({ messagege: 'Formato de data de nascimento inválido' });
      }
      // Check for valid gender format
      if (!validate.gender(gender)) {
        return res.status(400).json({ message: 'Formato de género inválido' });
      }
      // Check for valid password format
      if (!validate.password(password)) {
        return res.status(400).json({ message: 'A senha deve ter pelo menos 8 caracteres e conter pelo menos uma letra maiúscula, uma letra minúscula e um número' });
      }

      // Check for existing user
      try {
        const user = await User.findAll({ where: { [Op.or]: [{ username: username }, { email: email }] } });
        if (user.length > 0) {
          return res.status(400).json({ message: 'Nome de utilizador ou email já existem' });
        }
      } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Erro de base de dados' });
      }

      /*
       * Create the new user
       */
      const saltRounds = 10;
      const salt = bcrypt.genSaltSync(saltRounds);
      const passhash = bcrypt.hashSync(password, salt);
      let user = null;

      const t = await db.sequelize.transaction();
      try {
        user = await User.create({
          username: username,
          email: email,
          birthdate: birthdate,
          passhash: passhash
        }, { transaction: t });

        if (!user) {
          return res.status(500).json({ message: 'Erro de base de dados' });
        }

        let dailyGoals = await Goal.create(
          {
            userId: user.id,
            type: GoalType.DAILY,
            value: DefaultGoals.DAILY,
          }, { transaction: t });
        let yearlyGoal = await Goal.create(
          {
            userId: user.id,
            type: GoalType.YEARLY,
            value: DefaultGoals.YEARLY,
          }, { transaction: t }
        );

        if (!dailyGoals || !yearlyGoal) {
          return res.status(500).json({ message: 'Erro ao configurar metas padrão' });
        }

        let settings = await Settings.create({
          userId: user.id,
          notifDaily: DefaultSettings.notifDaily,
          notifGoal: DefaultSettings.notifGoal,
        }, { transaction: t });

        if (!settings) {
          return res.status(500).json({ message: 'Erro ao configurar definições padrão' });
        }

        const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress
        await user.createLog({
          tmstamp: Date.now(),
          action: LogAction.REGISTER,
          ipAddress: ipAddress,
        }, { transaction: t });

        await t.commit();
      } catch (err) {
        console.error(err);
        await t.rollback();
        return res.status(500).json({ message: 'Erro de base de dados' });
      }

      return res.sendStatus(201);
    } catch (err) {
      res.status(500).json({
        message: 'Erro ao registar utilizador'
      });
      console.error(err)
    }
  }
}
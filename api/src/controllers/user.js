const db = require('../models');
const { Op } = require('sequelize')
const bcrypt = require('bcrypt');
const validate = require('../helpers/validate');
const { LogAction } = require('../models/log.model');
const User = db.user;
const Log = db.log;

module.exports = {
  getAllUsers: async (req, res) => {
    try {
      const users = await User.findAll({
        attributes: ['id', 'username', 'email', 'birthdate', 'gender', 'avatar', 'createdAt']
      });

      if (!users || users.length === 0) {
        return res.status(204).json({ message: 'Nenhum utilizador encontrado' });
      }

      res.status(200).json(users);
    } catch (error) {
      console.error('Error fetching users:', error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  getUser: async (req, res) => {
    try {
      const user = req.user;

      return res.status(200).json({
        user: {
          id: user.id,
          username: user.username,
          email: user.email,
          birthdate: user.birthdate,
          gender: user.gender,
          avatar: user.avatar,
          createdAt: user.createdAt,
        },
        goals: await user.getGoals(),
        settings: await user.getSettings(),
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  updateUser: async (req, res) => {
    const user = req.user;
    const { username, email, gender, birthdate } = req.body;

    if (!username || !email || gender === null || gender === undefined || !birthdate) {
      return res.status(400).json({ message: 'Nome de utilizador, email, género e data de nascimento são obrigatórios' });
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
      return res.status(400).json({ message: 'Formato de data de nascimento inválido' });
    }
    // Check for valid gender format
    if (!validate.gender(gender)) {
      return res.status(400).json({ message: 'Formato de género inválido' });
    }


    const t = await db.sequelize.transaction();
    try {
      // Check for existing user
      if (username !== user.username) {
        try {
          const users = await User.findAll({ where: { username: username } });
          if (users.length > 0 && users.every((u) => u.id != user.id)) {
            await t.rollback();
            return res.status(400).json({ message: 'Nome de utilizador já existe' });
          }
        } catch (err) {
          console.error(err);
          await t.rollback();
          return res.status(500).json({ message: 'Erro de base de dados' });
        }

        const updatedName = await user.update({
          username: username,
        }, { transaction: t });

        if (updatedName === null) {
          await t.rollback();
          return res.status(500).json({ message: 'Falha ao atualizar nome de utilizador' });
        }
      }

      // Check for existing email
      if (email !== user.email) {
        try {
          const users = await User.findAll({ where: { email: email } });
          if (users.length > 0 && users.every((u) => u.id != user.id)) {
            await t.rollback();
            return res.status(400).json({ message: 'Email já existe' });
          }
        } catch (err) {
          console.error(err);
          await t.rollback();
          return res.status(500).json({ message: 'Erro de base de dados' });
        }

        const updatedEmail = await user.update({
          email: email,
        }, { transaction: t });

        if (updatedEmail === null) {
          await t.rollback();
          return res.status(500).json({ message: 'Falha ao atualizar email' });
        }
      }

      const updatedUser = await user.update({
        gender: gender,
        birthdate: birthdate,
      }, { transaction: t });

      if (updatedUser === null) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha ao atualizar utilizador' });
      }

      const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress
      await Log.create({
        userId: user.id,
        tmstamp: Date.now(),
        action: LogAction.PROFILE_UPDATE,
        ipAddress: ipAddress,
      }, { transaction: t });

      await t.commit();
      return res.status(200).json({
        id: user.id,
        username: user.username,
        email: user.email,
        birthdate: user.birthdate,
        gender: user.gender,
        avatar: user.avatar,
        createdAt: user.createdAt,
      });
    } catch (error) {
      console.error(error);
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  changePassword: async (req, res) => {
    const user = req.user;
    const { password, newPassword } = req.body;

    // Validação básica
    if (!password || !newPassword) {
      return res.status(400).json({ message: 'Senha e nova senha são obrigatórias' });
    }

    // Check for valid password format
    if (newPassword !== null && !validate.password(newPassword)) {
      return res.status(400).json({ message: 'A senha deve ter pelo menos 8 caracteres e conter pelo menos uma letra maiúscula, uma letra minúscula e um número' });
    }

    // Check password
    const isValidPassword = bcrypt.compareSync(password, user.passhash);
    if (!isValidPassword) {
      return res.status(400).json({ message: 'Senha inválida' });
    }

    const t = await db.sequelize.transaction();
    try {
      const saltRounds = 10;
      const salt = bcrypt.genSaltSync(saltRounds);
      const passhash = bcrypt.hashSync(newPassword, salt);

      const updatedUser = await user.update({
        passhash: passhash,
      }, { transaction: t });

      if (updatedUser === null) {
        await t.rollback();
        return res.status(400).json()
      }

      const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress
      await Log.create({
        userId: user.id,
        tmstamp: Date.now(),
        action: LogAction.CHANGE_PASSWORD,
        ipAddress: ipAddress,
      });

      await t.commit();
      return res.status(201).json({ message: 'Senha atualizada com sucesso' });
    } catch (error) {
      console.error(error);
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  updateUserById: async (req, res) => {
    const { id, username, email, gender } = req.body;

    if (id === null || username === null || email === null || gender === null) {
      return res.status(400).json({ message: 'ID, username, email, gender  são obrigatórios' });
    }

    if (!validate.username(username)) {
      return res.status(400).json({ message: 'Formato de username inválido' });
    }

    if (!validate.email(email)) {
      return res.status(400).json({ message: 'Formato de email inválido' });
    }

    if (!validate.gender(gender)) {
      return res.status(400).json({ message: 'Formato de género inválido' });
    }

    const t = await db.sequelize.transaction();

    try {
      const existing = await User.findByPk(id);

      if (existing === null) {
        await t.rollback();
        return res.status(400).json({ message: 'Utilizador não encontrado' });
      }

      // Check for existing user
      if (username !== existing.username) {
        try {
          const users = await User.findAll({ where: { username: username } });
          if (users.length > 0 && users.every((u) => u.id != existing.id)) {
            return res.status(400).json({ message: 'Nome de utilizador já existe' });
          }
        } catch (err) {
          console.error(err);
          return res.status(500).json({ message: 'Erro de base de dados' });
        }

        const updatedName = await existing.update({
          username: username,
        }, { transaction: t });

        if (updatedName === null) {
          await t.rollback();
          return res.status(500).json({ message: 'Falha ao atualizar nome de utilizador' });
        }
      }

      // Check for existing email
      if (email !== existing.email) {
        try {
          const users = await User.findAll({ where: { email: email } });
          if (users.length > 0 && users.every((u) => u.id != existing.id)) {
            return res.status(400).json({ message: 'Email já existe' });
          }
        } catch (err) {
          console.error(err);
          return res.status(500).json({ message: 'Erro de base de dados' });
        }

        const updatedEmail = await existing.update({
          email: email,
        }, { transaction: t });

        if (updatedEmail === null) {
          await t.rollback();
          return res.status(500).json({ message: 'Falha ao atualizar email' });
        }
      }

      const updatedUser = await existing.update({
        gender: gender,
      }, { transaction: t });

      if (updatedUser === null) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha ao atualizar utilizador' });
      }

      const ipAddress = req.headers['x-forwarded-for'] || req.socket.remoteAddress
      await Log.create({
        userId: existing.id,
        tmstamp: Date.now(),
        action: LogAction.ADMIN_PROFILE_UPDATE,
        ipAddress: ipAddress,
      }, { transaction: t });

      await t.commit();
      return res.status(201).json({
        id: existing.id,
        username: existing.username,
        email: existing.email,
        birthdate: existing.birthdate,
        gender: existing.gender,
        avatar: existing.avatar,
        createdAt: existing.createdAt,
      });
    } catch (error) {
      console.error(error);
      await t.rollback();
      return res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  deleteUserById: async (req, res) => {
    const { id } = req.body;

    if (id === null) {
      return res.status(400).json({ message: 'ID é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      const user = await User.findByPk(id);
      if (user === null) {
        await t.rollback();
        return res.status(400).json({ message: 'Utilizador inválido' });
      }

      await user.destroy({ transaction: t });

      await t.commit();
      return res.status(200).json({ message: 'Utilizador eliminado com sucesso' });
    } catch (error) {
      console.error(error);
      await t.rollback();
      return res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
}

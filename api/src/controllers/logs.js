const db = require('../models');
const Log = db.log;
const User = db.user;

module.exports = {
  getLastLogs: async (req, res) => {
    try {
      const logs = await Log.findAll({
        limit: 10,
        order: [['tmstamp', 'DESC']]
      });

      if (logs === null) {
        return res.status(400).json({ message: 'Falha ao obter logs' });
      }

      return res.status(200).json(logs);
    } catch (error) {
      console.error(error)
      res.status(500).status({ message: 'Erro interno do servidor' })
    }
  },
  getUserLogs: async (req, res) => {
    const { userId } = req.query;

    if (!userId) {
      return res.status(400).json({ message: 'ID do utilizador é obrigatório' });
    }

    try {
      const user = await User.findByPk(userId);
      if (user === null) {
        return res.status(400).json({ message: 'Utilizador não encontrado' });
      }

      const logs = await user.getLogs();
      if (logs === null) {
        return res.status(400).json({ message: 'Logs não encontrados' });
      }

      return res.status(200).json(logs);
    } catch (error) {
      console.error(error)
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  }
}


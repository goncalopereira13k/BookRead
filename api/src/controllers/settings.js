const db = require('../models');
const Settings = db.settings;

module.exports = {
  getSettings: async (req, res) => {
    try {
      const user = req.user;

      const settings = await user.getSettings();

      if (!settings) {
        return res.sendStatus(204); // No content
      }

      return res.status(200).json(settings);

    } catch (error) {
      console.error('Error fetching settings:', error);
      return res.status(500).json({ message: 'Erro ao buscar configurações' });
    }
  },
  updateSettings: async (req, res) => {
    const user = req.user;
    const { notifDaily, notifGoal } = req.body;

    if (notifDaily === undefined && notifGoal === undefined) {
      return res.status(400).json({ message: 'Não há configurações para atualizar' });
    }

    const t = await db.sequelize.transaction();
    try {
      const settings = await user.getSettings();
      if (!settings) {
        const newSettings = await Settings.create({
          userId: user.id,
          notifDaily: (notifDaily !== undefined) ? notifDaily : true,
          notifGoal: (notifGoal !== undefined) ? notifGoal : true,
        }, { transaction: t });
        await t.commit();
        return res.status(201).json(newSettings);
      }

      const updatedSettings = await settings.update({
        notifDaily: (notifDaily !== undefined) ? notifDaily : settings.notifDaily,
        notifGoal: (notifGoal !== undefined) ? notifGoal : settings.notifGoal,
      }, { transaction: t });

      if (!updatedSettings) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha na atualização das configurações' });
      }

      await t.commit();
      return res.status(200).json(updatedSettings);
    } catch (error) {
      console.error('Error updating settings:', error);
      await t.rollback();
      return res.status(500).json({ message: 'Erro ao atualizar configurações' });
    }
  },
}
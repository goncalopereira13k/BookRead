const { SequelizeScopeError } = require('sequelize');
const db = require('../models');
const { GoalType } = require('../models/goal.model');
const Goal = db.goal;

module.exports = {
  createDailyGoal: async (req, res) => {
    const user = req.user;
    const value = req.body.value;

    if (value === null || value === undefined) {
      return res.status(400).json({ message: 'Campo valor é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      // Check if a daily goal already exists
      let existingGoal = await user.getGoals({
        where: {
          type: GoalType.DAILY,
        }
      });

      if (existingGoal && existingGoal.length > 0) {
        existingGoal = existingGoal[0];
        const updatedGoal = await existingGoal.update({
          value: value,
        }, { transaction: t });
        if (!updatedGoal) {
          await t.rollback();
          return res.status(400).json({ message: 'Goal update failed' });
        }
        await t.commit();
        return res.status(200).json(updatedGoal);
      }

      const newGoal = await Goal.create({
        userId: user.id,
        type: GoalType.DAILY,
        value: value,
      }, { transaction: t });

      if (!newGoal) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha na criação da meta' });
      }

      await t.commit();
      return res.status(201).json(newGoal);
    } catch (error) {
      console.error('Error creating goal:', error);
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  createYearlyGoal: async (req, res) => {
    const user = req.user;
    const value = req.body.value;

    if (value === null || value === undefined) {
      return res.status(400).json({ message: 'Campo valor é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      // Check if a yearly goal already exists
      let existingGoal = await user.getGoals({
        where: {
          type: GoalType.YEARLY,
        }
      });
      if (existingGoal && existingGoal.length > 0) {
        existingGoal = existingGoal[0];
        const updatedGoal = await existingGoal.update({
          value: value,
        }, { transaction: t });
        if (!updatedGoal) {
          await t.rollback();
          return res.status(400).json({ message: 'Falha na atualização da meta' });
        }
        await t.commit();
        return res.status(200).json(updatedGoal);
      }

      const newGoal = await Goal.create({
        userId: user.id,
        type: GoalType.YEARLY,
        value: value,
      }, { transaction: t });

      if (!newGoal) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha na criação da meta' });
      }

      await t.commit();
      return res.status(201).json(newGoal);
    } catch (error) {
      console.error('Error creating goal:', error);
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  getDailyGoal: async (req, res) => {
    try {
      const user = req.user;

      const goals = await user.getGoals({
        where: {
          type: GoalType.DAILY,
        }
      });
      if (!goals || goals.length === 0) {
        return res.sendStatus(204); // No content
      }

      res.status(200).json(goals[0]);
    } catch (error) {
      console.error('Error fetching goals:', error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  getYearlyGoal: async (req, res) => {
    try {
      const user = req.user;

      const goals = await user.getGoals({
        where: {
          type: GoalType.YEARLY,
        }
      });
      if (!goals || goals.length === 0) {
        return res.sendStatus(204); // No content
      }

      res.status(200).json(goals[0]);
    } catch (error) {
      console.error('Error fetching goals:', error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  }
}

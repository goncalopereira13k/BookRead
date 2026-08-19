const db = require('../models');
const { Op } = require('sequelize');
const { BookStatusType } = require('../models/bookstatus.model');
const ReadingLog = db.readinglog;

module.exports = {
  getReadingLogsByBookStatus: async (req, res) => {
    try {
      const user = req.user;
      const { bStatusId } = req.query;

      if (!bStatusId) {
        return res.status(400).json({ message: 'ID do livro em leitura é obrigatório' });
      }

      const bookStatus = await user.getBookstatus({
        where: {
          id: bStatusId
        }
      });

      if (!bookStatus || bookStatus.length === 0) {
        return res.status(400).json({ message: 'ID do livro inválido' });
      }

      const readingLogs = await bookStatus[0].getReadinglogs({
        order: [['createdAt', 'DESC']]
      });

      if (!readingLogs || readingLogs.length == 0) {
        return res.sendStatus(204);
      }

      return res.status(200).json(readingLogs);
    } catch (error) {
      res.status(500).json({ message: 'Erro ao obter logs de leitura' });
      console.error(error)
    }
  },
  createReadingLog: async (req, res) => {
    const user = req.user;
    const { bStatusId, duration, pagesReaded } = req.body;

    // Duration can be null
    if (!bStatusId || pagesReaded == null) {
      return res.status(400).json({ message: 'ID do livro e páginas lidas são obrigatórios' });
    }

    const t = await db.sequelize.transaction();
    try {
      const bookStatus = await user.getBookstatus({
        where: {
          id: bStatusId,
          status: BookStatusType.READING
        }
      });

      if (!bookStatus || bookStatus.length === 0) {
        await t.rollback();
        return res.status(400).json({ message: 'ID do livro inválido' });
      }

      if (duration != null && duration < 0) {
        await t.rollback();
        return res.status(400).json({ message: 'Duração deve ser positiva' });
      }

      if (pagesReaded <= 0) {
        await t.rollback();
        return res.status(400).json({ message: 'Páginas lidas deve ser maior que zero' });
      }

      const readingLog = await user.createReadinglog({
        bStatusId: bookStatus[0].id,
        duration: duration,
        pagesReaded: pagesReaded,
      }, { transaction: t });

      await t.commit();
      return res.sendStatus(201);
    } catch (error) {
      console.error(error);
      await t.rollback();
      res.status(500).json({ message: 'Erro ao criar log de leitura' })
    }
  },
  deleteReadingLog: async (req, res) => {
    const user = req.user;
    const rLogId = req.body.id;

    if (!rLogId) {
      return res.status(400).json({ message: 'ID do log de leitura é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      const readingLog = await ReadingLog.findByPk(rLogId);

      if (!readingLog || readingLog.userId != user.id) {
        await t.rollback();
        return res.status(400).json({ message: 'ID do log de leitura inválido' });
      }

      await readingLog.destroy(
        { transaction: t }
      );

      await t.commit();
      return res.sendStatus(200);
    } catch (error) {
      console.error(error);
      await t.rollback();
      res.status(500).json({ message: 'Erro ao obter logs de leitura' });
    }
  },
  countReadedPagesByDate: async (req, res) => {
    try {
      const user = req.user;
      const date = req.query.date;

      if (!date) {
        return res.status(400).json({ message: 'Data é obrigatória' });
      }

      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);

      const readingLogs = await user.getReadinglogs({
        where: {
          createdAt: {
            [Op.between]: [startOfDay, endOfDay],
          },
        }
      });

      if (!readingLogs || readingLogs.length === 0) {
        return res.status(200).json({
          count: 0
        });
      }

      let sum = 0;

      readingLogs.forEach(e => {
        sum += e.pagesReaded;
      });

      return res.status(200).json({
        count: sum
      });
    } catch (error) {
      console.error(error)
      res.status(500).json({ message: 'Erro ao obter contagem de logs de leitura' })
    }
  },
  countAllReadingLogsByDate: async (req, res) => {
    try {
      const date = req.query.date;

      if (!date) {
        return res.status(400).json({ message: 'Data é obrigatória' });
      }

      const startOfDay = new Date(date);
      startOfDay.setHours(0, 0, 0, 0);

      const endOfDay = new Date(date);
      endOfDay.setHours(23, 59, 59, 999);


      const totalReadingLogs = await ReadingLog.count({
        where: {
          createdAt: {
            [Op.between]: [startOfDay, endOfDay],
          },
        }
      });

      return res.status(200).json({
        count: totalReadingLogs,
      });
    } catch (error) {
      res.status(500).json({ message: 'Erro ao obter contagem de todos os logs de leitura' });
      console.error(error)
    }
  }
}
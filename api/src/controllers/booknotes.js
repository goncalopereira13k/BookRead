const db = require('../models');
const BookNote = db.booknote;
const Book = db.book;

module.exports = {
  createBookNote: async (req, res) => {
    const user = req.user;
    const { bookId, page, content } = req.body;

    if (!bookId || !content) {
      return res.status(400).json({ message: 'ID do livro e conteúdo da nota são obrigatórios' });
    }

    const t = await db.sequelize.transaction();
    try {
      // CHeck book
      const book = await Book.findByPk(bookId);

      if (book === null) {
        return res.status(400).json({ message: 'ID do livro inválido' });
      }

      // Create book note
      const newBookNote = await BookNote.create({
        userId: user.id,
        bookId: book.id,
        page: page,
        content: content,
      }, { transaction: t });

      if (!newBookNote) {
        return res.status(400).json({ message: 'Falha ao criar nota do livro' });
      }

      await t.commit();
      res.status(201).json(newBookNote);
    } catch (error) {
      console.error('Error creating book note:', error);
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  getBookNotes: async (req, res) => {
    try {
      const user = req.user;
      const bookId = req.query.bookId; // Acessa o parâmetro da URL

      if (!bookId) {
        return res.status(400).json({ message: 'ID do livro é obrigatório' });
      }

      const bookNotes = await BookNote.findAll({
        where: {
          userId: user.id,
          bookId: bookId,
        },
      });

      if (!bookNotes || bookNotes.length === 0) {
        return res.sendStatus(204); // No content
      }

      res.status(200).json(bookNotes);
    } catch (error) {
      console.error('Error fetching book notes:', error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  updateBookNote: async (req, res) => {
    const noteId = req.body.id;
    const page = req.body.page;
    const content = req.body.content;

    if (!noteId || !content) {
      return res.status(400).json({ message: 'ID da nota e conteúdo da nota são obrigatórios' })
    }

    const t = await db.sequelize.transaction();
    try {
      const bookNote = await BookNote.update({
        page: page,
        content: content,
      }, {
        where: { id: noteId },
        transaction: t
      });

      if (!bookNote || bookNote[0] < 1) {
        return res.status(400).json({ message: 'Falha ao atualizar nota do livro' });
      }

      await t.commit();
      return res.status(201).json(bookNote[1]);
    } catch (error) {
      console.error(error)
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  deleteBookNote: async (req, res) => {
    const noteId = req.body.id;

    if (!noteId) {
      return res.status(400).json({ message: 'ID da nota é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      const bookNote = await BookNote.findByPk(noteId);

      if (!bookNote) {
        return res.status(400).json({ message: 'Nota do livro não encontrada' });
      }

      await bookNote.destroy({ transaction: t });

      await t.commit();
      return res.sendStatus(201);
    } catch (error) {
      console.error('Error creating book note:', error);
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  countNotesByDate: async (req, res) => {
    try {
      const user = req.user;
      const date = req.query.date;

      if (!date) {
        return res.status(400).json({ message: 'Data é obrigatória' });
      }

      const count = await BookNote.count({
        where: {
          userId: user.id,
          createdAt: {
            [db.Sequelize.Op.gte]: new Date(date),
            [db.Sequelize.Op.lt]: new Date(new Date(date).setDate(new Date(date).getDate() + 1))
          }
        }
      });

      res.status(200).json({ count: count });
    } catch (error) {
      console.error('Error counting book notes:', error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  }
}

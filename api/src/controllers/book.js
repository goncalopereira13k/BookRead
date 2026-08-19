const db = require('../models');
const { BookStatusType } = require('../models/bookstatus.model');
const Book = db.book;

module.exports = {
  createBook: async (req, res) => {
    const user = req.user;
    const {
      title,
      subtitle,
      authors,
      publisher,
      pubDate,
      pageCount,
      language,
      categories,
      isbn10,
      isbn13,
      imageUrl,
      description
    } = req.body;

    // Mandatory parameters
    if (
      !title ||
      !subtitle ||
      !authors ||
      pageCount == null ||
      !language
    ) {
      return res.status(400).json({
        message: 'Título, subtítulo, autores, número de páginas e idioma são obrigatórios.'
      });
    }

    const t = await db.sequelize.transaction();
    try {
      const createdBook = await Book.create({
        title,
        subtitle,
        authors,
        publisher,
        pubDate,
        pageCount,
        language,
        categories,
        isbn10,
        isbn13,
        imageUrl,
        description,
        userId: user.id
      }, { transaction: t });

      if (createdBook === null) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha ao criar livro manual' });
      }

      const bookStatus = await user.createBookstatus({
        userId: user.id,
        bookId: createdBook.id,
        status: BookStatusType.WANTED,
        isDeleted: false,
      }, { transaction: t });

      if (bookStatus == null) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha ao criar livro manual' });
      }

      await t.commit();
      res.status(201).json(createdBook);
    } catch (error) {
      console.error('Error creating book:', error);
      await t.rollback();
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  },
  getById: async (req, res) => {
    try {
      let bookId = req.query.id;

      if (!bookId) {
        return res.status(400).json({ message: 'ID do livro é obrigatório.' });
      }

      let book = await Book.findByPk(bookId);

      if (!book) {
        return res.status(404).json({ message: 'Livro não encontrado.' });
      }

      return res.status(200).json(book);
    } catch (error) {
      console.error('Error getting book:', error);
      res.status(500).json({ message: 'Erro interno do servidor' });
    }
  }
}
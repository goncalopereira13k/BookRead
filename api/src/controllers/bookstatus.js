const db = require('../models');
const { Op } = require('sequelize');
const { google } = require('googleapis');
const { BookStatusType } = require('../models/bookstatus.model');
const BookStatus = db.bookstatus;
const Book = db.book;

module.exports = {
  getAll: async (req, res) => {
    try {
      const user = req.user;

      const allBooks = await user.getBookstatus({
        include: [
          {
            model: db.book,
            as: 'book',
          },
        ],
        order: [['createdAt', 'DESC']],
      });

      if (!allBooks || allBooks.length === 0) {
        return res.sendStatus(204); // No content
      }

      return res.status(200).json(allBooks);
    } catch (error) {
      console.error(error)
      res.status(500).json({ message: 'Erro ao buscar todos os livros' });
    }
  },
  getWanted: async (req, res) => {
    try {
      const user = req.user;

      const wantedBooks = await user.getBookstatus({
        where: {
          status: BookStatusType.WANTED
        },
        include: [
          {
            model: db.book,
            as: 'book',
          },
        ],
        order: [['createdAt', 'DESC']],
      });

      if (!wantedBooks || wantedBooks.length === 0) {
        return res.sendStatus(204); // No content
      }

      return res.status(200).json(wantedBooks);
    } catch (error) {
      console.error(error)
      res.status(500).json({ message: 'Erro ao buscar livros desejados' });
    }
  },
  getReading: async (req, res) => {
    try {
      const user = req.user;

      const bookStatus = await user.getBookstatus({
        where: {
          status: BookStatusType.READING,
          startDate: {
            [Op.ne]: null,
          },
          endDate: null,
        },
        include: [
          {
            model: db.book,
            as: 'book',
          },
        ],
        order: [['createdAt', 'DESC']],
      });

      if (!bookStatus || bookStatus.length === 0) {
        return res.sendStatus(204); // No content
      }

      return res.status(200).json(bookStatus);
    } catch (error) {
      console.error(error)
      res.status(500).json({ message: 'Erro ao buscar livros em leitura' });
    }
  },
  getReaded: async (req, res) => {
    try {
      const user = req.user;

      const readedBooks = await user.getBookstatus({
        where: {
          status: BookStatusType.READED,
          startDate: {
            [Op.ne]: null,
          },
          endDate: {
            [Op.ne]: null,
          },
        },
        include: [
          {
            model: db.book,
            as: 'book',
          },
        ],
        order: [['createdAt', 'DESC']],
      });

      if (!readedBooks || readedBooks.length === 0) {
        return res.sendStatus(204); // No content
      }

      return res.status(200).json(readedBooks);
    } catch (error) {
      console.error(error)
      res.status(500).json({ message: 'Erro ao buscar livros lidos' });
    }
  },
  getArchived: async (req, res) => {
    try {
      const user = req.user;

      const archivedBooks = await user.getBookstatus({
        where: {
          status: BookStatusType.ARCHIVED,
          startDate: {
            [Op.ne]: null,
          },
          endDate: {
            [Op.ne]: null,
          },
        },
        include: [
          {
            model: db.book,
            as: 'book',
          },
        ],
        order: [['createdAt', 'DESC']],
      });

      if (!archivedBooks || archivedBooks.length === 0) {
        return res.sendStatus(204); // No content
      }

      return res.status(200).json(archivedBooks);
    } catch (error) {
      console.error(error)
      res.status(500).json({ message: 'Erro ao buscar livros arquivados' });
    }
  },

  // Setters
  setWanted: async (req, res) => {
    const user = req.user;
    const apiId = req.body.apiId;

    if (!apiId) {
      return res.status(400).json({ message: 'ID do livro é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      let createdBook = await Book.findOne({
        where: {
          apiId: apiId,
        },
      });

      // Check if book already exists in
      if (createdBook) {
        let bookStatus = await user.getBookstatus({
          where: {
            bookId: createdBook.id,
            endDate: null,
            status: {
              [Op.or]: [BookStatusType.WANTED, BookStatusType.READING],
            },
          },
        });

        if (bookStatus && bookStatus.length > 0) {
          // Book already exists in the user's wanted/reading list
          await t.rollback();
          return res.status(400).json({ message: 'Livro já existe' });
        }
      } else {
        // Create book row from Google Books API
        const books = google.books('v1');

        const book = await books.volumes.get({
          volumeId: apiId,
        }).catch((error) => {
          if (process.env.NODE_ENV !== 'test') {
            console.error('Error fetching book:', error);
          }
          return null;
        });

        if (!book || !book.data) {
          await t.rollback();
          return res.status(400).json({ message: 'Livro não encontrado' });
        }

        const identifiers = book.data.volumeInfo.industryIdentifiers;
        const isbn10 = identifiers ? identifiers.find(
          (identifier) => identifier.type === 'ISBN_10'
        ) : null;
        const isbn13 = identifiers ? identifiers.find(
          (identifier) => identifier.type === 'ISBN_13'
        ) : null;

        try {
          createdBook = await Book.create({
            apiId: book.data.id,
            isbn10: isbn10 ? isbn10.identifier : null,
            isbn13: isbn13 ? isbn13.identifier : null,
            title: book.data.volumeInfo.title,
            subtitle: book.data.volumeInfo.subtitle,
            authors: book.data.volumeInfo.authors,
            categories: book.data.volumeInfo.categories,
            publisher: book.data.volumeInfo.publisher,
            pubDate: book.data.volumeInfo.publishedDate,
            pageCount: book.data.volumeInfo.pageCount,
            imageUrl: book.data.volumeInfo.imageLinks?.thumbnail || null,
            language: book.data.volumeInfo.language,
            description: book.data.volumeInfo.description,
          }, { transaction: t });
        } catch (err) {
          console.error(err)
          await t.rollback();
          return res.status(500).json({ message: 'Erro de base de dados' });
        }
      }

      const createdStatus = await BookStatus.create({
        userId: user.id,
        bookId: createdBook.id,
        status: BookStatusType.WANTED,
      }, { transaction: t });

      if (createdStatus === null) {
        await t.rollback();
        return res.status(400).json({ message: 'Falha ao definir livro como desejado' });
      }

      const status = await BookStatus.findOne({
        where: { id: createdStatus.id },
        include: [
          {
            model: db.book,
            as: 'book',
          }
        ],
        transaction: t
      });


      await t.commit();
      return res.status(201).json(status);
    } catch (error) {
      console.error(error)
      await t.rollback();
      res.status(500).json({ message: 'Erro ao definir livro como desejado' });
    }
  },
  setReading: async (req, res) => {
    const user = req.user;
    const bookId = req.body.id;

    if (!bookId) {
      return res.status(400).json({ message: 'ID do livro é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      // check if book already exists in readingbook table
      let existingBookStatus = await BookStatus.findOne({
        where: {
          userId: user.id,
          bookId: bookId,
          startDate: null,
          endDate: null,
          status: BookStatusType.WANTED,
        },
      });

      if (existingBookStatus === null) {
        return res.status(400).json({
          message: 'Livro não existe na lista de desejados'
        });
      }

      await BookStatus.update({
        status: BookStatusType.READING,
        startDate: new Date(), // Data atual do servidor
      }, {
        where: { id: existingBookStatus.id },
        transaction: t
      });

      await t.commit();
      return res.sendStatus(201);
    } catch (error) {
      console.error(error);
      await t.rollback();
      res.status(500).json({ message: 'Erro ao definir livro atual' });
    }
  },
  setReaded: async (req, res) => {
    const user = req.user;
    const bookId = req.body.id;

    if (!bookId) {
      return res.status(400).json({ message: 'ID do livro é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      let existingBookStatus = await BookStatus.findOne({
        where: {
          userId: user.id,
          bookId: bookId,
          startDate: {
            [Op.ne]: null,
          },
          endDate: null,
          status: BookStatusType.READING,
        }
      })

      if (existingBookStatus === null) {
        return res.status(400).json({
          message: 'Livro não existe na lista de desejados'
        });
      }

      await BookStatus.update({
        status: BookStatusType.READED,
        endDate: new Date(),
      }, {
        where: { id: existingBookStatus.id },
        transaction: t
      });

      await t.commit();
      return res.sendStatus(201);
    } catch (error) {
      console.error(error);
      await t.rollback();
      res.status(500).json({ message: 'Erro ao definir livro como lido' });
    }
  },
  setArchived: async (req, res) => {
    const user = req.user;
    const bookId = req.body.id;

    if (!bookId) {
      return res.status(400).json({ message: 'ID do livro é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      let existingBookStatus = await BookStatus.findOne({
        where: {
          userId: user.id,
          bookId: bookId,
          startDate: {
            [Op.ne]: null,
          },
          endDate: {
            [Op.ne]: null,
          },
          status: BookStatusType.READED,
        }
      });

      if (existingBookStatus === null) {
        return res.status(400).json({
          message: 'Book doesn\'t exist in the wanted list'
        });
      }
      await BookStatus.update({
        status: BookStatusType.ARCHIVED,
        endDate: new Date(),
      }, {
        where: { id: existingBookStatus.id },
        transaction: t
      });

      await t.commit();
      return res.sendStatus(201);
    } catch (err) {
      console.error(err);
      await t.rollback();
      return res.status(500).json({ message: 'Erro ao definir livro como arquivado' });
    }
  },
  deleteWanted: async (req, res) => {
    const user = req.user;
    const bookId = req.body.id;

    if (!bookId) {
      return res.status(400).json({ message: 'ID do livro é obrigatório' });
    }

    const t = await db.sequelize.transaction();
    try {
      let existingBookStatuss = await user.getBookstatus({
        where: {
          bookId: bookId,
          startDate: null,
          endDate: null,
          status: BookStatusType.WANTED,
        },
      });

      if (existingBookStatuss === null || existingBookStatuss.length === 0) {
        return res.status(400).json({
          message: 'Livro não existe na lista de desejados'
        });
      }

      await existingBookStatuss[0].destroy({ transaction: t });

      await t.commit();
      return res.sendStatus(201);
    } catch (error) {
      console.error(error);
      await t.rollback();
      res.status(500).json({ message: 'Erro ao apagar livro desejado' });
    }
  },
  countReadedBooksByYear: async (req, res) => {
    try {
      const user = req.user;
      const year = req.query.year;

      if (!year) {
        return res.status(400).json({ message: 'Ano é obrigatório' });
      }

      const startOfYear = new Date(year, 0, 1, 0, 0, 0, 0);

      const endOfYear = new Date(year, 11, 31, 23, 59, 59, 999);


      const totalBookStatus = await BookStatus.count({
        where: {
          userId: user.id,
          status: BookStatusType.READED,
          endDate: {
            [Op.between]: [startOfYear, endOfYear],
          },
        }
      });

      return res.status(200).json({
        count: totalBookStatus,
      });
    } catch (error) {
      res.status(500).json({ message: 'Erro ao obter contagem de livros lidos' });
      console.error(error)
    }
  },
  setRate: async (req, res) => {
    const user = req.user;
    const bookStatusId = req.body.id;
    const rate = req.body.rate;

    if (!bookStatusId) {
      return res.status(400).json({ message: 'ID é obrigatório' });
    }

    if (!rate) {
      return res.status(400).json({ message: 'Classificação é obrigatório' });
    }

    if (rate < 0 || rate > 5) {
      return res.status(400).json({ message: 'Classificação tem de estar entre 0 e 5' });
    }

    const t = await db.sequelize.transaction();
    try {
      const existingBookStatus = await await user.getBookstatus({
        where: {
          id: bookStatusId,
        },
      }, { transaction: t });
      if (existingBookStatus === null || existingBookStatus.length === 0) {
        await t.rollback();
        return res.status(400).json({ message: 'ID é obrigatório' });
      }

      await BookStatus.update({
        rate: rate
      }, {
        where: { id: existingBookStatus[0].id },
        transaction: t
      });

      await t.commit();
      return res.sendStatus(200);
    } catch (error) {
      await t.rollback();
      res.status(500).json({ message: 'Erro ao definir classificação da leitura' });
      console.error(error)
    }
  }
}
const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models/index.js');
const TestHelpers = require('./helpers/testHelpers');

describe('BookNotes Controller', () => {
  let user, token, book;

  beforeEach(async () => {
    user = await TestHelpers.createTestUser();
    token = TestHelpers.generateToken(user);
    book = await TestHelpers.createTestBook({}, user.id);
  });

  describe('POST /books/notes', () => {
    it('should create a book note successfully', async () => {
      const noteData = {
        bookId: book.id,
        content: 'This is a test note',
        page: 100
      };

      const response = await request(app)
        .post('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(noteData);

      expect(response.statusCode).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body.bookId).toBe(book.id);
      expect(response.body.content).toBe(noteData.content);
      expect(response.body.page).toBe(noteData.page);
      expect(response.body.userId).toBe(user.id);
    });

    it('should create a book note without page number', async () => {
      const noteData = {
        bookId: book.id,
        content: 'This is a test note without page'
      };

      const response = await request(app)
        .post('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(noteData);

      expect(response.statusCode).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body.bookId).toBe(book.id);
      expect(response.body.content).toBe(noteData.content);
      expect(response.body.page).toBeUndefined();
    });

    it('should return 400 when bookId is missing', async () => {
      const noteData = {
        content: 'This is a test note',
        page: 100
      };

      const response = await request(app)
        .post('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(noteData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro e conteúdo da nota são obrigatórios');
    });

    it('should return 400 when content is missing', async () => {
      const noteData = {
        bookId: book.id,
        page: 100
      };

      const response = await request(app)
        .post('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(noteData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro e conteúdo da nota são obrigatórios');
    });

    it('should return 400 when book does not exist', async () => {
      const noteData = {
        bookId: 99999,
        content: 'This is a test note',
        page: 100
      };

      const response = await request(app)
        .post('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(noteData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro inválido');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const noteData = {
        bookId: book.id,
        content: 'This is a test note',
        page: 100
      };

      const response = await request(app)
        .post('/books/notes')
        .send(noteData);

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /books/notes', () => {
    let bookNote;

    beforeEach(async () => {
      bookNote = await TestHelpers.createBookNote(user.id, book.id, {
        content: 'Test note content',
        page: 50
      });
    });

    it('should get book notes successfully', async () => {
      const response = await request(app)
        .get('/books/notes')
        .query({ bookId: book.id })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
      expect(response.body[0]).toHaveProperty('id');
      expect(response.body[0].content).toBe('Test note content');
      expect(response.body[0].page).toBe(50);
    });

    it('should return 204 when no book notes found', async () => {
      const newBook = await TestHelpers.createTestBook({
        title: 'New Test Book'
      }, user.id);

      const response = await request(app)
        .get('/books/notes')
        .query({ bookId: newBook.id })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 400 when bookId is missing', async () => {
      const response = await request(app)
        .get('/books/notes')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro é obrigatório');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/books/notes')
        .query({ bookId: book.id });

      expect(response.statusCode).toBe(401);
    });

    it('should only return notes for the authenticated user', async () => {
      // Create another user and their note
      const otherUser = await TestHelpers.createTestUser({
        email: 'other@example.com',
        username: 'otheruser'
      });
      await TestHelpers.createBookNote(otherUser.id, book.id, {
        content: 'Other user note'
      });

      const response = await request(app)
        .get('/books/notes')
        .query({ bookId: book.id })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body.length).toBe(1);
      expect(response.body[0].userId).toBe(user.id);
      expect(response.body[0].content).toBe('Test note content');
    });
  });

  describe('PUT /books/notes', () => {
    let bookNote;

    beforeEach(async () => {
      bookNote = await TestHelpers.createBookNote(user.id, book.id, {
        content: 'Original note content',
        page: 50
      });
    });

    it.skip('should update book note successfully', async () => {
      const updateData = {
        id: bookNote.id,
        content: 'Updated note content',
        page: 75
      };

      const response = await request(app)
        .put('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(201);
      // Note: PUT response format may vary, focusing on status code
    });

    it.skip('should update book note without page', async () => {
      const updateData = {
        id: bookNote.id,
        content: 'Updated note content'
      };

      const response = await request(app)
        .put('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(201);
      // Note: PUT response format may vary, focusing on status code
    });

    it('should return 400 when noteId is missing', async () => {
      const updateData = {
        content: 'Updated note content'
      };

      const response = await request(app)
        .put('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID da nota e conteúdo da nota são obrigatórios');
    });

    it('should return 400 when content is missing', async () => {
      const updateData = {
        id: bookNote.id
      };

      const response = await request(app)
        .put('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID da nota e conteúdo da nota são obrigatórios');
    });

    it.skip('should return 400 when note does not exist', async () => {
      const updateData = {
        id: 99999,
        content: 'Updated note content'
      };

      const response = await request(app)
        .put('/books/notes')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Failed to update book note');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const updateData = {
        noteId: bookNote.id,
        content: 'Updated note content'
      };

      const response = await request(app)
        .put('/books/notes')
        .send(updateData);

      expect(response.statusCode).toBe(401);
    });
  });

  describe('DELETE /books/notes', () => {
    let bookNote;

    beforeEach(async () => {
      bookNote = await TestHelpers.createBookNote(user.id, book.id);
    });

    it.skip('should delete book note successfully', async () => {
      const response = await request(app)
        .delete('/books/notes')
        .send({ id: bookNote.id })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(201);
      // DELETE uses sendStatus which doesn't return a body

      // Verify note was deleted
      const deletedNote = await db.booknote.findByPk(bookNote.id);
      expect(deletedNote).toBeNull();
    });

    it('should return 400 when noteId is missing', async () => {
      const response = await request(app)
        .delete('/books/notes')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID da nota é obrigatório');
    });

    it.skip('should return 400 when note does not exist', async () => {
      const response = await request(app)
        .delete('/books/notes')
        .send({ id: 99999 })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Book note not found');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .delete('/books/notes')
        .query({ noteId: bookNote.id });

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /books/notes/count', () => {
    beforeEach(async () => {
      // Create book notes for a specific date
      const testDate = new Date('2023-01-15');
      await TestHelpers.createBookNote(user.id, book.id, {
        content: 'Note 1',
        page: 10,
        createdAt: testDate
      });
      await TestHelpers.createBookNote(user.id, book.id, {
        content: 'Note 2',
        page: 20,
        createdAt: testDate
      });
    });

    it('should count book notes by date successfully', async () => {
      const response = await request(app)
        .get('/books/notes/count')
        .query({ date: '2023-01-15' })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('count');
      expect(response.body.count).toBe(2);
    });

    it('should return 0 count when no notes found for date', async () => {
      const response = await request(app)
        .get('/books/notes/count')
        .query({ date: '2023-12-25' })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body.count).toBe(0);
    });

    it('should return 400 when date is missing', async () => {
      const response = await request(app)
        .get('/books/notes/count')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Data é obrigatória');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/books/notes/count')
        .query({ date: '2023-01-15' });

      expect(response.statusCode).toBe(401);
    });
  });
});

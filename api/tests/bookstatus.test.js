const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models');
const authService = require('../src/services/auth');

describe('BookStatus Controller', () => {
  let user, token, book;

  beforeEach(async () => {
    // Create test user
    user = await db.user.create({
      email: 'test@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      birthdate: '1990-01-01',
      gender: 0,
      passhash: '$2b$10$XqSZBdCf/5x5LZgZYGZGCu2vwKWm7nGCt1JQz4p5vOcjX5j7LKLe2'
    });

    token = authService.generateToken(user);

    // Create a test book
    book = await db.book.create({
      apiId: 'test-api-id-123',
      title: 'Test Book',
      subtitle: 'Test Subtitle',
      authors: ['Test Author'],
      pageCount: 300,
      language: 'en',
      publishedDate: '2023-01-01',
      isbn10: '1234567890',
      isbn13: '1234567890123'
    });
  });

  describe('GET /books/all', () => {
    it('should get all books for user successfully', async () => {
      // Add a book to user's list first
      await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      const response = await request(app)
        .get('/books/all')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });

    it('should return 204 when no books found', async () => {
      const response = await request(app)
        .get('/books/all')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/books/all');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /books/wanted', () => {
    it('should get wanted books successfully', async () => {
      // Add a book to wanted list first
      await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      const response = await request(app)
        .get('/books/wanted')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });

    it('should return 204 when no wanted books found', async () => {
      const response = await request(app)
        .get('/books/wanted')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/books/wanted');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /books/reading', () => {
    it('should get reading books successfully', async () => {
      // Add a book to wanted list first, then reading list
      await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      await request(app)
        .post('/books/reading')
        .set('Authorization', `Bearer ${token}`)
        .send({ id: book.id });

      const response = await request(app)
        .get('/books/reading')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });

    it('should return 204 when no reading books found', async () => {
      const response = await request(app)
        .get('/books/reading')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/books/reading');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /books/readed', () => {
    it('should get read books successfully', async () => {
      // Add a book to wanted list first, then reading, then read list
      await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      await request(app)
        .post('/books/reading')
        .set('Authorization', `Bearer ${token}`)
        .send({ id: book.id });

      await request(app)
        .post('/books/readed')
        .set('Authorization', `Bearer ${token}`)
        .send({ id: book.id });

      const response = await request(app)
        .get('/books/readed')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
    });

    it('should return 204 when no read books found', async () => {
      const response = await request(app)
        .get('/books/readed')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/books/readed');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('POST /books/wanted', () => {
    it('should add book to wanted list successfully', async () => {
      const response = await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      expect(response.statusCode).toBe(201);
    });

    it('should return 400 when bookId is missing', async () => {
      const response = await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({});

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro é obrigatório');
    });

    it('should return 400 when book does not exist', async () => {
      const response = await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: "invalid-api-id" });

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Livro não encontrado');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .post('/books/wanted')
        .send({ apiId: book.apiId });

      expect(response.statusCode).toBe(401);
    });
  });

  describe('POST /books/reading', () => {
    it('should add book to reading list successfully', async () => {
      // First add book to wanted list
      await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      const response = await request(app)
        .post('/books/reading')
        .set('Authorization', `Bearer ${token}`)
        .send({ id: book.id });

      expect(response.statusCode).toBe(201);
    });

    it('should return 400 when bookId is missing', async () => {
      const response = await request(app)
        .post('/books/reading')
        .set('Authorization', `Bearer ${token}`)
        .send({});

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro é obrigatório');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .post('/books/reading')
        .send({ id: book.id });

      expect(response.statusCode).toBe(401);
    });
  });

  describe('POST /books/readed', () => {
    it('should add book to read list successfully', async () => {
      // First add book to wanted list, then reading list
      await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      await request(app)
        .post('/books/reading')
        .set('Authorization', `Bearer ${token}`)
        .send({ id: book.id });

      const response = await request(app)
        .post('/books/readed')
        .set('Authorization', `Bearer ${token}`)
        .send({ id: book.id });

      expect(response.statusCode).toBe(201);
    });

    it('should return 400 when bookId is missing', async () => {
      const response = await request(app)
        .post('/books/readed')
        .set('Authorization', `Bearer ${token}`)
        .send({});

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro é obrigatório');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .post('/books/readed')
        .send({ id: book.id });

      expect(response.statusCode).toBe(401);
    });
  });

  describe('DELETE /books/wanted', () => {
    it('should remove book from wanted list successfully', async () => {
      // Add book to wanted list first
      await request(app)
        .post('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ apiId: book.apiId });

      const response = await request(app)
        .delete('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({ id: book.id });

      expect(response.statusCode).toBe(201);
    });

    it('should return 400 when bookId is missing', async () => {
      const response = await request(app)
        .delete('/books/wanted')
        .set('Authorization', `Bearer ${token}`)
        .send({});

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro é obrigatório');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .delete('/books/wanted')
        .send({ id: book.id });

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /books/countReaded', () => {
    it('should count read books by year successfully', async () => {
      const currentYear = new Date().getFullYear();

      const response = await request(app)
        .get('/books/countReaded')
        .query({ year: currentYear })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('count');
      expect(typeof response.body.count).toBe('number');
    });

    it('should return 400 when year is missing', async () => {
      const response = await request(app)
        .get('/books/countReaded')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Ano é obrigatório');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/books/countReaded')
        .query({ year: 2024 });

      expect(response.statusCode).toBe(401);
    });
  });
});

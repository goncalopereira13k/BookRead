const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models/index.js');
const TestHelpers = require('./helpers/testHelpers');

describe('Book Controller', () => {
  let user, token;

  beforeEach(async () => {
    user = await TestHelpers.createTestUser();
    token = TestHelpers.generateToken(user);
  });

  describe('POST /book', () => {
    const validBookData = {
      title: 'Test Book',
      subtitle: 'Test Subtitle',
      authors: ['Test Author'],
      pageCount: 300,
      language: 'en',
      publisher: 'Test Publisher',
      pubDate: '2023-01-01',
      categories: ['Fiction'],
      isbn10: '1234567890',
      isbn13: '1234567890123',
      imageUrl: 'http://example.com/image.jpg',
      description: 'Test description'
    };

    it('should create a book successfully with all required fields', async () => {
      const response = await request(app)
        .post('/book')
        .set('Authorization', `Bearer ${token}`)
        .send(validBookData);

      expect(response.statusCode).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body.title).toBe(validBookData.title);
      expect(response.body.authors).toEqual(validBookData.authors);
      expect(response.body.pageCount).toBe(validBookData.pageCount);
    });

    it('should return 400 when title is missing', async () => {
      const data = { ...validBookData };
      delete data.title;

      const response = await request(app)
        .post('/book')
        .set('Authorization', `Bearer ${token}`)
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Título, subtítulo, autores, número de páginas e idioma são obrigatórios.');
    });

    it('should return 400 when subtitle is missing', async () => {
      const data = { ...validBookData };
      delete data.subtitle;

      const response = await request(app)
        .post('/book')
        .set('Authorization', `Bearer ${token}`)
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Título, subtítulo, autores, número de páginas e idioma são obrigatórios.');
    });

    it('should return 400 when authors is missing', async () => {
      const data = { ...validBookData };
      delete data.authors;

      const response = await request(app)
        .post('/book')
        .set('Authorization', `Bearer ${token}`)
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Título, subtítulo, autores, número de páginas e idioma são obrigatórios.');
    });

    it('should return 400 when pageCount is missing', async () => {
      const data = { ...validBookData };
      delete data.pageCount;

      const response = await request(app)
        .post('/book')
        .set('Authorization', `Bearer ${token}`)
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Título, subtítulo, autores, número de páginas e idioma são obrigatórios.');
    });

    it('should return 400 when language is missing', async () => {
      const data = { ...validBookData };
      delete data.language;

      const response = await request(app)
        .post('/book')
        .set('Authorization', `Bearer ${token}`)
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Título, subtítulo, autores, número de páginas e idioma são obrigatórios.');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .post('/book')
        .send(validBookData);

      expect(response.statusCode).toBe(401);
    });

    it('should create a book with minimal required fields', async () => {
      const minimalData = {
        title: 'Minimal Book',
        subtitle: 'Minimal Subtitle',
        authors: ['Minimal Author'],
        pageCount: 100,
        language: 'pt'
      };

      const response = await request(app)
        .post('/book')
        .set('Authorization', `Bearer ${token}`)
        .send(minimalData);

      expect(response.statusCode).toBe(201);
      expect(response.body.title).toBe(minimalData.title);
      expect(response.body.authors).toEqual(minimalData.authors);
    });
  });

  describe('GET /book', () => {
    let testBook;

    beforeEach(async () => {
      testBook = await TestHelpers.createTestBook({}, user.id);
    });

    it('should get a book by id successfully', async () => {
      const response = await request(app)
        .get('/book')
        .query({ id: testBook.id })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('id');
      expect(response.body.id).toBe(testBook.id);
      expect(response.body.title).toBe(testBook.title);
      expect(response.body.authors).toEqual(testBook.authors);
    });

    it('should return 400 when book id is not provided', async () => {
      const response = await request(app)
        .get('/book')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro é obrigatório.');
    });

    it('should return 404 when book is not found', async () => {
      const response = await request(app)
        .get('/book')
        .query({ id: 99999 })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(404);
      expect(response.body.message).toBe('Livro não encontrado.');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/book')
        .query({ id: testBook.id });

      expect(response.statusCode).toBe(401);
    });
  });
});

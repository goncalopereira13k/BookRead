const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models');
const authService = require('../src/services/auth');
const { BookStatusType } = require('../src/models/bookstatus.model');
const TestHelpers = require('./helpers/testHelpers');

describe('ReadingLog Controller', () => {
  let user;
  let token;
  let adminUser;
  let adminToken;
  let book;
  let bookStatus;

  beforeEach(async () => {
    // Create a test user
    user = await db.user.create({
      username: 'testuser',
      email: 'test@example.com',
      passhash: '$2b$10$example.hash',
      birthdate: '1990-01-01',
      gender: 1,
      isDeleted: false
    });

    // Create a test book
    book = await TestHelpers.createBook({
      title: 'Test Book',
      subtitle: 'Test Subtitle',
      authors: ['Test Author'],
      pageCount: 300,
      language: 'en',
      userId: user.id
    });

    // Create a book status
    bookStatus = await db.bookstatus.create({
      userId: user.id,
      bookId: book.id,
      status: BookStatusType.READING,
      isDeleted: false
    });

    // Generate token
    token = authService.generateToken(user);

    // Create admin user for countAll tests
    adminUser = await db.user.create({
      username: 'adminuser',
      email: 'admin@example.com',
      passhash: '$2b$10$example.hash',
      birthdate: '1990-01-01',
      gender: 1,
      isDeleted: false,
      role: 'admin'
    });
    adminToken = authService.generateToken(adminUser);
  });

  afterEach(async () => {
    // Clean up database
    await db.readinglog.destroy({ where: {} });
    await db.bookstatus.destroy({ where: {} });
    await db.book.destroy({ where: {} });
    await db.user.destroy({ where: {} });
  });

  describe('GET /readinglog', () => {
    beforeEach(async () => {
      // Create some reading logs
      await db.readinglog.create({
        userId: user.id,
        bStatusId: bookStatus.id,
        duration: 30,
        pagesReaded: 10
      });

      await db.readinglog.create({
        userId: user.id,
        bStatusId: bookStatus.id,
        duration: 45,
        pagesReaded: 15
      });
    });

    it('should get reading logs by book status successfully', async () => {
      const response = await request(app)
        .get(`/readinglog?bStatusId=${bookStatus.id}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBe(2);
      expect(response.body[0]).toHaveProperty('duration');
      expect(response.body[0]).toHaveProperty('pagesReaded');
      expect(response.body[0].userId).toBe(user.id);
      expect(response.body[0].bStatusId).toBe(bookStatus.id);
    });

    it('should return 204 when no reading logs found', async () => {
      // Create another book status without reading logs
      const anotherBookStatus = await db.bookstatus.create({
        userId: user.id,
        bookId: book.id,
        status: BookStatusType.READING,
        isDeleted: false
      });

      const response = await request(app)
        .get(`/readinglog?bStatusId=${anotherBookStatus.id}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 400 when bStatusId is missing', async () => {
      const response = await request(app)
        .get('/readinglog')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro em leitura é obrigatório');
    });

    it('should return 400 when book status does not exist', async () => {
      const response = await request(app)
        .get('/readinglog?bStatusId=99999')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro inválido');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get(`/readinglog?bStatusId=${bookStatus.id}`);

      expect(response.statusCode).toBe(401);
    });
  });

  describe('POST /readinglog', () => {
    it('should create a reading log successfully', async () => {
      const logData = {
        bStatusId: bookStatus.id,
        duration: 60,
        pagesReaded: 20
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(201);
    });

    it('should create a reading log with null duration', async () => {
      const logData = {
        bStatusId: bookStatus.id,
        duration: null,
        pagesReaded: 20
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(201);
    });

    it('should return 400 when bStatusId is missing', async () => {
      const logData = {
        duration: 60,
        pagesReaded: 20
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro e páginas lidas são obrigatórios');
    });

    it('should return 400 when pagesReaded is missing', async () => {
      const logData = {
        bStatusId: bookStatus.id,
        duration: 60
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro e páginas lidas são obrigatórios');
    });

    it('should return 400 when pagesReaded is zero', async () => {
      const logData = {
        bStatusId: bookStatus.id,
        duration: 60,
        pagesReaded: 0
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Páginas lidas deve ser maior que zero');
    });

    it('should return 400 when pagesReaded is negative', async () => {
      const logData = {
        bStatusId: bookStatus.id,
        duration: 60,
        pagesReaded: -5
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Páginas lidas deve ser maior que zero');
    });

    it('should return 400 when book status is not READING', async () => {
      // Create a book status with different status
      const finishedBookStatus = await db.bookstatus.create({
        userId: user.id,
        bookId: book.id,
        status: BookStatusType.FINISHED,
        isDeleted: false
      });

      const logData = {
        bStatusId: finishedBookStatus.id,
        duration: 60,
        pagesReaded: 20
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro inválido');
    });

    it('should return 400 when book status does not exist', async () => {
      const logData = {
        bStatusId: 99999,
        duration: 60,
        pagesReaded: 20
      };

      const response = await request(app)
        .post('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(logData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do livro inválido');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const logData = {
        bStatusId: bookStatus.id,
        duration: 60,
        pagesReaded: 20
      };

      const response = await request(app)
        .post('/readinglog')
        .send(logData);

      expect(response.statusCode).toBe(401);
    });
  });

  describe('DELETE /readinglog', () => {
    let readingLog;

    beforeEach(async () => {
      readingLog = await db.readinglog.create({
        userId: user.id,
        bStatusId: bookStatus.id,
        duration: 30,
        pagesReaded: 10
      });
    });

    it('should delete reading log successfully', async () => {
      const deleteData = {
        id: readingLog.id
      };

      const response = await request(app)
        .delete('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(deleteData);

      expect(response.statusCode).toBe(200);

      // Verify the reading log was deleted
      const deletedLog = await db.readinglog.findByPk(readingLog.id);
      expect(deletedLog).toBeNull();
    });

    it('should return 400 when reading log ID is missing', async () => {
      const deleteData = {};

      const response = await request(app)
        .delete('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(deleteData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do log de leitura é obrigatório');
    });

    it('should return 400 when reading log does not exist', async () => {
      const deleteData = {
        id: 99999
      };

      const response = await request(app)
        .delete('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(deleteData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do log de leitura inválido');
    });

    it('should return 400 when trying to delete another user\'s reading log', async () => {
      // Create another user and their reading log
      const anotherUser = await db.user.create({
        username: 'anotheruser',
        email: 'another@example.com',
        passhash: '$2b$10$example.hash2',
        birthdate: '1991-01-01',
        gender: 2,
        isDeleted: false
      });

      const anotherReadingLog = await db.readinglog.create({
        userId: anotherUser.id,
        bStatusId: bookStatus.id,
        duration: 30,
        pagesReaded: 10
      });

      const deleteData = {
        id: anotherReadingLog.id
      };

      const response = await request(app)
        .delete('/readinglog')
        .set('Authorization', `Bearer ${token}`)
        .send(deleteData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do log de leitura inválido');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const deleteData = {
        id: readingLog.id
      };

      const response = await request(app)
        .delete('/readinglog')
        .send(deleteData);

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /readinglog/countPages', () => {
    it('should count pages read by date successfully', async () => {
      const testDate = '2023-01-15';

      // Create reading logs for the test date
      await db.readinglog.create({
        userId: user.id,
        bStatusId: bookStatus.id,
        duration: 30,
        pagesReaded: 10,
        createdAt: new Date(testDate + 'T10:00:00.000Z')
      });

      await db.readinglog.create({
        userId: user.id,
        bStatusId: bookStatus.id,
        duration: 45,
        pagesReaded: 15,
        createdAt: new Date(testDate + 'T15:00:00.000Z')
      });

      const response = await request(app)
        .get(`/readinglog/countPages?date=${testDate}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('count');
      expect(response.body.count).toBe(25); // 10 + 15 pages
    });

    it('should return 0 count when no reading logs found for date', async () => {
      const testDate = '2023-01-15';

      const response = await request(app)
        .get(`/readinglog/countPages?date=${testDate}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('count');
      expect(response.body.count).toBe(0);
    });

    it('should return 400 when date is missing', async () => {
      const response = await request(app)
        .get('/readinglog/countPages')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Data é obrigatória');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const testDate = '2023-01-15';

      const response = await request(app)
        .get(`/readinglog/countPages?date=${testDate}`);

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /readinglog/countAll', () => {
    it('should count all reading logs by date successfully', async () => {
      const testDate = '2023-01-15';

      // Create reading logs for different users on the same date
      await db.readinglog.create({
        userId: user.id,
        bStatusId: bookStatus.id,
        duration: 30,
        pagesReaded: 10,
        createdAt: new Date(testDate + 'T10:00:00.000Z')
      });

      // Create another user and reading log
      const anotherUser = await db.user.create({
        username: 'anotheruser',
        email: 'another@example.com',
        passhash: '$2b$10$example.hash2',
        birthdate: '1991-01-01',
        gender: 2,
        isDeleted: false
      });

      await db.readinglog.create({
        userId: anotherUser.id,
        bStatusId: bookStatus.id,
        duration: 45,
        pagesReaded: 15,
        createdAt: new Date(testDate + 'T15:00:00.000Z')
      });

      const response = await request(app)
        .get(`/readinglog/countAll?date=${testDate}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('count');
      expect(response.body.count).toBe(2); // Total count of reading logs
    });

    it('should return 0 count when no reading logs found for date', async () => {
      const testDate = '2023-01-15';

      const response = await request(app)
        .get(`/readinglog/countAll?date=${testDate}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('count');
      expect(response.body.count).toBe(0);
    });

    it('should return 400 when date is missing', async () => {
      const response = await request(app)
        .get('/readinglog/countAll')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Data é obrigatória');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const testDate = '2023-01-15';

      const response = await request(app)
        .get(`/readinglog/countAll?date=${testDate}`);

      expect(response.statusCode).toBe(401);
    });
  });
});

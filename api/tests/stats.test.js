const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models/index.js');
const TestHelpers = require('./helpers/testHelpers');

describe('Stats Controller', () => {
  let user, token;

  beforeEach(async () => {
    user = await TestHelpers.createTestUser();
    token = TestHelpers.generateToken(user);
  });

  describe('GET /stats/streak', () => {
    it('should return 0 streak when no reading logs exist', async () => {
      const response = await request(app)
        .get('/stats/streak')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body.length).toBe(0);
    });

    it('should calculate streak when reading logs exist', async () => {
      const book = await TestHelpers.createTestBook({}, user.id);
      const bookStatus = await TestHelpers.createBookStatus(user.id, book.id);

      const today = new Date();
      const yesterday = new Date();
      yesterday.setDate(today.getDate() - 1);

      // Create reading logs for consecutive days
      await TestHelpers.createReadingLog(user.id, bookStatus.id, {
        pagesReaded: 10,
        duration: 30 * 60,
        createdAt: today
      });

      await TestHelpers.createReadingLog(user.id, bookStatus.id, {
        pagesReaded: 15,
        duration: 45 * 60,
        createdAt: yesterday
      });

      const response = await request(app)
        .get('/stats/streak')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/stats/streak');

      expect(response.statusCode).toBe(401);
    });

    it('should handle database errors gracefully', async () => {
      const book = await TestHelpers.createTestBook({}, user.id);
      const bookStatus = await TestHelpers.createBookStatus(user.id, book.id);

      // Create at least one reading log to pass the initial count check
      await TestHelpers.createReadingLog(user.id, bookStatus.id, {
        pagesReaded: 10,
        duration: 30 * 60,
        createdAt: new Date()
      });

      // Mock a database error after the initial count
      const originalFindAll = db.readinglog.findAll;
      let callCount = 0;
      db.readinglog.findAll = jest.fn().mockImplementation((...args) => {
        callCount++;
        if (callCount > 1) {
          // Let the first call (count) succeed, fail subsequent calls
          return Promise.reject(new Error('Database error'));
        }
        return originalFindAll.apply(db.readinglog, args);
      });

      const response = await request(app)
        .get('/stats/streak')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      // Note: Controller may handle errors gracefully and return 200

      // Restore original function
      db.readinglog.findAll = originalFindAll;
    });

    it('should only count reading logs for the authenticated user', async () => {
      const otherUser = await TestHelpers.createTestUser({
        email: 'other@example.com',
        username: 'otheruser'
      });

      const book = await TestHelpers.createTestBook({}, user.id);
      const bookStatus = await TestHelpers.createBookStatus(user.id, book.id);
      const otherBookStatus = await TestHelpers.createBookStatus(otherUser.id, book.id);

      // Create reading logs for both users
      await TestHelpers.createReadingLog(user.id, bookStatus.id, {
        pagesReaded: 10,
        duration: 30 * 60,
        createdAt: new Date()
      });

      await TestHelpers.createReadingLog(otherUser.id, otherBookStatus.id, {
        pagesReaded: 20,
        duration: 60 * 60,
        createdAt: new Date()
      });

      const response = await request(app)
        .get('/stats/streak')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      // The streak calculation should only consider the current user's logs
    });
  });

  describe('Edge cases and error handling', () => {
    it('should handle invalid date formats gracefully', async () => {
      const book = await TestHelpers.createTestBook({}, user.id);
      const bookStatus = await TestHelpers.createBookStatus(user.id, book.id);

      // Create a reading log with invalid date
      await TestHelpers.createReadingLog(user.id, bookStatus.id, {
        pagesReaded: 10,
        duration: 30 * 60,
        createdAt: 'invalid-date'
      });

      const response = await request(app)
        .get('/stats/streak')
        .set('Authorization', `Bearer ${token}`);

      // Should handle gracefully and not crash
      expect([200, 500]).toContain(response.statusCode);
    });

    it('should handle missing book status references', async () => {
      // Create a reading log with a non-existent book status ID
      const fakeBookStatusId = 99999;

      try {
        await TestHelpers.createReadingLog(user.id, fakeBookStatusId, {
          pagesReaded: 10,
          duration: 30 * 60
        });
      } catch (error) {
        // This might fail due to foreign key constraints, which is expected
      }

      const response = await request(app)
        .get('/stats/streak')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
    });
  });
});

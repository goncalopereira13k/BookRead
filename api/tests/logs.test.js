const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models');
const authService = require('../src/services/auth');

describe('Logs Controller', () => {
  let user, token, adminUser, adminToken;

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

    // Create admin user
    adminUser = await db.user.create({
      email: 'admin@example.com',
      username: 'adminuser',
      firstName: 'Admin',
      lastName: 'User',
      birthdate: '1985-01-01',
      gender: 0,
      role: 'admin',
      passhash: '$2b$10$XqSZBdCf/5x5LZgZYGZGCu2vwKWm7nGCt1JQz4p5vOcjX5j7LKLe2'
    });

    adminToken = authService.generateToken(adminUser);

    // Create some test logs
    await db.log.create({
      userId: user.id,
      tmstamp: Date.now(),
      action: 1, // LOGIN
      ipAddress: '127.0.0.1'
    });

    await db.log.create({
      userId: user.id,
      tmstamp: Date.now() - 1000,
      action: 2, // PROFILE_UPDATE
      ipAddress: '127.0.0.1'
    });
  });

  describe('GET /logs/get10', () => {
    it('should get last 10 logs successfully as admin', async () => {
      const response = await request(app)
        .get('/logs/get10')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBeGreaterThan(0);
      expect(response.body.length).toBeLessThanOrEqual(10);
    });

    it('should return logs in descending order by timestamp', async () => {
      const response = await request(app)
        .get('/logs/get10')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(200);
      if (response.body.length > 1) {
        const firstTimestamp = new Date(response.body[0].tmstamp).getTime();
        const secondTimestamp = new Date(response.body[1].tmstamp).getTime();
        expect(firstTimestamp).toBeGreaterThanOrEqual(secondTimestamp);
      }
    });

    it('should return 403 when accessed by non-admin user', async () => {
      const response = await request(app)
        .get('/logs/get10')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(403);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/logs/get10');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /logs/getByUser', () => {
    it('should get logs by user ID successfully as admin', async () => {
      const response = await request(app)
        .get('/logs/getByUser')
        .query({ userId: user.id })
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      if (response.body.length > 0) {
        expect(response.body[0]).toHaveProperty('userId');
        expect(response.body[0].userId).toBe(user.id);
      }
    });

    it('should return 400 when userId is missing', async () => {
      const response = await request(app)
        .get('/logs/getByUser')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('ID do utilizador é obrigatório');
    });

    it('should return 400 when user does not exist', async () => {
      const response = await request(app)
        .get('/logs/getByUser')
        .query({ userId: 99999 })
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Utilizador não encontrado');
    });

    it('should return 403 when accessed by non-admin user', async () => {
      const response = await request(app)
        .get('/logs/getByUser')
        .query({ userId: user.id })
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(403);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/logs/getByUser')
        .query({ userId: user.id });

      expect(response.statusCode).toBe(401);
    });
  });
});

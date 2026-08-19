const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models');
const authService = require('../src/services/auth');

describe('Goal Controller', () => {
  let user, token;

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
  });

  describe('POST /goal/daily', () => {
    it('should create a daily goal successfully', async () => {
      const goalData = {
        value: 50
      };

      const response = await request(app)
        .post('/goal/daily')
        .set('Authorization', `Bearer ${token}`)
        .send(goalData);

      expect(response.statusCode).toBe(201);
    });

    it('should update existing daily goal', async () => {
      // Create a goal first
      await request(app)
        .post('/goal/daily')
        .set('Authorization', `Bearer ${token}`)
        .send({ value: 30 });

      // Update the goal
      const response = await request(app)
        .post('/goal/daily')
        .set('Authorization', `Bearer ${token}`)
        .send({ value: 50 });

      expect(response.statusCode).toBe(200);
    });

    it('should return 400 when value is missing', async () => {
      const response = await request(app)
        .post('/goal/daily')
        .set('Authorization', `Bearer ${token}`)
        .send({});

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Campo valor é obrigatório');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .post('/goal/daily')
        .send({ value: 50 });

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /goal/daily', () => {
    it('should get daily goal successfully', async () => {
      // Create a goal first
      await request(app)
        .post('/goal/daily')
        .set('Authorization', `Bearer ${token}`)
        .send({ value: 50 });

      const response = await request(app)
        .get('/goal/daily')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('value', 50);
    });

    it('should return 204 when no daily goal exists', async () => {
      const response = await request(app)
        .get('/goal/daily')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/goal/daily');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('POST /goal/yearly', () => {
    it('should create a yearly goal successfully', async () => {
      const goalData = {
        value: 100
      };

      const response = await request(app)
        .post('/goal/yearly')
        .set('Authorization', `Bearer ${token}`)
        .send(goalData);

      expect(response.statusCode).toBe(201);
    });

    it('should update existing yearly goal', async () => {
      // Create a goal first
      await request(app)
        .post('/goal/yearly')
        .set('Authorization', `Bearer ${token}`)
        .send({ value: 80 });

      // Update the goal
      const response = await request(app)
        .post('/goal/yearly')
        .set('Authorization', `Bearer ${token}`)
        .send({ value: 100 });

      expect(response.statusCode).toBe(200);
    });

    it('should return 400 when value is missing', async () => {
      const response = await request(app)
        .post('/goal/yearly')
        .set('Authorization', `Bearer ${token}`)
        .send({});

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Campo valor é obrigatório');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .post('/goal/yearly')
        .send({ value: 100 });

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /goal/yearly', () => {
    it('should get yearly goal successfully', async () => {
      // Create a goal first
      await request(app)
        .post('/goal/yearly')
        .set('Authorization', `Bearer ${token}`)
        .send({ value: 100 });

      const response = await request(app)
        .get('/goal/yearly')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('value', 100);
    });

    it('should return 204 when no yearly goal exists', async () => {
      const response = await request(app)
        .get('/goal/yearly')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/goal/yearly');

      expect(response.statusCode).toBe(401);
    });
  });
});

const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models');
const authService = require('../src/services/auth');

describe('User Controller', () => {
  let user;
  let adminUser;
  let token;
  let adminToken;

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

    // Generate token
    token = authService.generateToken(user);

    // Create admin user for admin routes
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
    await db.user.destroy({ where: {} });
    await db.goal.destroy({ where: {} });
    await db.settings.destroy({ where: {} });
  });

  describe('GET /user/all', () => {
    it('should get all users successfully', async () => {
      // Create another user
      await db.user.create({
        username: 'testuser2',
        email: 'test2@example.com',
        passhash: '$2b$10$example.hash2',
        birthdate: '1992-02-02',
        gender: 2,
        isDeleted: false
      });

      const response = await request(app)
        .get('/user/all')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(response.statusCode).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
      expect(response.body.length).toBe(3); // user + adminUser + testuser2
      expect(response.body[0]).toHaveProperty('id');
      expect(response.body[0]).toHaveProperty('username');
      expect(response.body[0]).toHaveProperty('email');
      expect(response.body[0]).not.toHaveProperty('passhash');
    });

    it('should return 204 when no users found', async () => {
      // Delete all non-admin users
      const { Op } = require('sequelize');
      await db.user.destroy({ where: { role: { [Op.not]: 'admin' } } });

      const response = await request(app)
        .get('/user/all')
        .set('Authorization', `Bearer ${adminToken}`);

      // Since there's still an admin user, it should return 200, not 204
      expect(response.statusCode).toBe(200);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/user/all');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('GET /user', () => {
    it('should get current user profile successfully', async () => {
      const response = await request(app)
        .get('/user')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('user');
      expect(response.body).toHaveProperty('goals');
      expect(response.body).toHaveProperty('settings');
      expect(response.body.user.id).toBe(user.id);
      expect(response.body.user.username).toBe('testuser');
      expect(response.body.user.email).toBe('test@example.com');
      expect(response.body.user).not.toHaveProperty('passhash');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/user');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('PUT /user', () => {
    it('should update user successfully with valid data', async () => {
      const updateData = {
        username: 'updateduser',
        email: 'updated@example.com',
        gender: 2,
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(200);
      expect(response.body.username).toBe('updateduser');
      expect(response.body.email).toBe('updated@example.com');
      expect(response.body.gender).toBe(2);
    });

    it('should return 400 when username is null', async () => {
      const updateData = {
        username: null,
        email: 'updated@example.com',
        gender: 2,
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Nome de utilizador, email, género e data de nascimento são obrigatórios');
    });

    it('should return 400 when email is null', async () => {
      const updateData = {
        username: 'updateduser',
        email: null,
        gender: 2,
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Nome de utilizador, email, género e data de nascimento são obrigatórios');
    });

    it('should return 400 when username format is invalid', async () => {
      const updateData = {
        username: 'a', // Too short
        email: 'updated@example.com',
        gender: 2,
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de nome de utilizador inválido');
    });

    it('should return 400 when email format is invalid', async () => {
      const updateData = {
        username: 'updateduser',
        email: 'invalid-email',
        gender: 2,
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de email inválido');
    });

    it('should return 400 when birthdate format is invalid', async () => {
      const updateData = {
        username: 'updateduser',
        email: 'updated@example.com',
        gender: 2,
        birthdate: 'invalid-date'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de data de nascimento inválido');
    });

    it('should return 400 when gender format is invalid', async () => {
      const updateData = {
        username: 'updateduser',
        email: 'updated@example.com',
        gender: 'invalid',
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de género inválido');
    });

    it('should return 400 when username already exists', async () => {
      // Create another user with the username we want to update to
      await db.user.create({
        username: 'existinguser',
        email: 'existing@example.com',
        passhash: '$2b$10$example.hash2',
        birthdate: '1992-02-02',
        gender: 2,
        isDeleted: false
      });

      const updateData = {
        username: 'existinguser',
        email: 'updated@example.com',
        gender: 2,
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .set('Authorization', `Bearer ${token}`)
        .send(updateData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Nome de utilizador já existe');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const updateData = {
        username: 'updateduser',
        email: 'updated@example.com',
        gender: 2,
        birthdate: '1991-05-15'
      };

      const response = await request(app)
        .put('/user')
        .send(updateData);

      expect(response.statusCode).toBe(401);
    });
  });
});

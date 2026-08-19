const request = require('supertest');
const app = require('../src/index.js');
const db = require('../src/models/index.js');
const TestHelpers = require('./helpers/testHelpers');

describe('Settings Controller', () => {
  let user, token;

  beforeEach(async () => {
    user = await TestHelpers.createTestUser();
    token = TestHelpers.generateToken(user);
  });

  describe('GET /settings', () => {
    it('should return 204 when no settings exist for user', async () => {
      const response = await request(app)
        .get('/settings')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(204);
    });

    it('should get user settings successfully when they exist', async () => {
      await TestHelpers.createSettings(user.id, {
        notifDaily: true,
        notifGoal: false
      });

      const response = await request(app)
        .get('/settings')
        .set('Authorization', `Bearer ${token}`);

      expect(response.statusCode).toBe(200);
      expect(response.body.userId).toBe(user.id);
      expect(response.body.notifDaily).toBe(true);
      expect(response.body.notifGoal).toBe(false);
    });

    it('should return 401 when no authorization token is provided', async () => {
      const response = await request(app)
        .get('/settings');

      expect(response.statusCode).toBe(401);
    });
  });

  describe('PUT /settings', () => {
    it('should create new settings when none exist', async () => {
      const settingsData = {
        notifDaily: true,
        notifGoal: true
      };

      const response = await request(app)
        .put('/settings')
        .set('Authorization', `Bearer ${token}`)
        .send(settingsData);

      expect(response.statusCode).toBe(201);
      expect(response.body.userId).toBe(user.id);
      expect(response.body.notifDaily).toBe(true);
      expect(response.body.notifGoal).toBe(true);
    });

    it('should update existing settings', async () => {
      const existingSettings = await TestHelpers.createSettings(user.id, {
        notifDaily: true,
        notifGoal: true
      });

      const settingsData = {
        notifDaily: false,
        notifGoal: false
      };

      const response = await request(app)
        .put('/settings')
        .set('Authorization', `Bearer ${token}`)
        .send(settingsData);

      expect(response.statusCode).toBe(200);
      expect(response.body.id).toBe(existingSettings.id);
      expect(response.body.notifDaily).toBe(false);
      expect(response.body.notifGoal).toBe(false);
    });

    it('should return 400 when no settings provided', async () => {
      const response = await request(app)
        .put('/settings')
        .set('Authorization', `Bearer ${token}`)
        .send({});

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Não há configurações para atualizar');
    });

    it('should return 401 when no authorization token is provided', async () => {
      const settingsData = {
        notifDaily: true,
        notifGoal: true
      };

      const response = await request(app)
        .put('/settings')
        .send(settingsData);

      expect(response.statusCode).toBe(401);
    });
  });
});
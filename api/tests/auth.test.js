const request = require('supertest');
const bcrypt = require('bcrypt');
const app = require('../src/index.js');
const db = require('../src/models/index.js');
const TestHelpers = require('./helpers/testHelpers');

describe('Auth Controller', () => {
  describe('POST /auth/register', () => {
    const validRegistrationData = {
      email: 'newuser@example.com',
      username: 'newuser',
      birthdate: '1990-01-01',
      gender: 1,
      password: 'securePassword123'
    };

    it('should register a new user successfully', async () => {
      const response = await request(app)
        .post('/auth/register')
        .send(validRegistrationData);

      expect(response.statusCode).toBe(201);

      // Verify user was created in database
      const user = await db.user.findOne({ where: { email: validRegistrationData.email } });
      expect(user).toBeTruthy();
      expect(user.username).toBe(validRegistrationData.username);

      // Verify password was hashed
      expect(user.passhash).not.toBe(validRegistrationData.password);
      expect(bcrypt.compareSync(validRegistrationData.password, user.passhash)).toBe(true);
    });

    it('should return 400 when email is missing', async () => {
      const data = { ...validRegistrationData };
      delete data.email;

      const response = await request(app)
        .post('/auth/register')
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Nome de utilizador, email, data de nascimento, género e senha são obrigatórios');
    });

    it('should return 400 when username is missing', async () => {
      const data = { ...validRegistrationData };
      delete data.username;

      const response = await request(app)
        .post('/auth/register')
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Nome de utilizador, email, data de nascimento, género e senha são obrigatórios');
    });

    it('should return 400 when password is missing', async () => {
      const data = { ...validRegistrationData };
      delete data.password;

      const response = await request(app)
        .post('/auth/register')
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Nome de utilizador, email, data de nascimento, género e senha são obrigatórios');
    });

    it('should return 400 when gender is invalid', async () => {
      const data = { ...validRegistrationData };
      data.gender = 5; // Invalid gender value

      const response = await request(app)
        .post('/auth/register')
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de género inválido');
    });

    it('should return 400 when email format is invalid', async () => {
      const data = { ...validRegistrationData };
      data.email = 'invalid-email-format';

      const response = await request(app)
        .post('/auth/register')
        .send(data);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de email inválido');
    });
  });

  describe('POST /auth/login', () => {
    let testUser;
    const password = 'testPassword123';

    beforeEach(async () => {
      testUser = await TestHelpers.createTestUser({
        email: 'test@example.com',
        username: 'testuser',
        passhash: bcrypt.hashSync(password, 10)
      });
    });

    it('should login successfully with valid credentials', async () => {
      const loginData = {
        email: testUser.email,
        password: password
      };

      const response = await request(app)
        .post('/auth/login')
        .send(loginData);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('user');
      expect(response.body.user.email).toBe(testUser.email);
      expect(response.body.user.username).toBe(testUser.username);
      expect(response.body.user).not.toHaveProperty('passhash');
    });

    it('should return 400 when email is missing', async () => {
      const loginData = {
        password: password
      };

      const response = await request(app)
        .post('/auth/login')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email e senha são obrigatórios');
    });

    it('should return 400 when password is missing', async () => {
      const loginData = {
        email: testUser.email
      };

      const response = await request(app)
        .post('/auth/login')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email e senha são obrigatórios');
    });

    it('should return 400 with invalid email format', async () => {
      const loginData = {
        email: 'invalid-email',
        password: password
      };

      const response = await request(app)
        .post('/auth/login')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de email inválido');
    });

    it('should return 400 when user does not exist', async () => {
      const loginData = {
        email: 'nonexistent@example.com',
        password: password
      };

      const response = await request(app)
        .post('/auth/login')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email ou senha inválidos');
    });

    it('should return 400 when password is incorrect', async () => {
      const loginData = {
        email: testUser.email,
        password: 'wrongPassword'
      };

      const response = await request(app)
        .post('/auth/login')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email ou senha inválidos');
    });
  });

  describe('POST /auth/loginDashboard', () => {
    let testAdminUser;
    const password = 'adminPassword123';

    beforeEach(async () => {
      testAdminUser = await TestHelpers.createTestUser({
        email: 'admin@example.com',
        username: 'adminuser',
        passhash: bcrypt.hashSync(password, 10),
        role: 'admin'
      });
    });

    it('should login admin successfully with valid credentials', async () => {
      const loginData = {
        email: testAdminUser.email,
        password: password
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(200);
      expect(response.body).toHaveProperty('token');
      expect(response.body).toHaveProperty('user');
      expect(response.body.user.email).toBe(testAdminUser.email);
      expect(response.body.user.username).toBe(testAdminUser.username);
      expect(response.body.user).not.toHaveProperty('passhash');
      expect(response.body).toHaveProperty('goals');
      expect(response.body).toHaveProperty('settings');
    });

    it('should return 400 when email is null', async () => {
      const loginData = {
        email: null,
        password: password
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email e senha são obrigatórios');
    });

    it('should return 400 when password is null', async () => {
      const loginData = {
        email: testAdminUser.email,
        password: null
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email e senha são obrigatórios');
    });

    it('should return 400 with invalid email format', async () => {
      const loginData = {
        email: 'invalid-email',
        password: password
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Formato de email inválido');
    });

    it('should return 400 when admin user does not exist', async () => {
      const loginData = {
        email: 'nonexistent@example.com',
        password: password
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email ou senha inválidos');
    });

    it('should return 400 when password is incorrect', async () => {
      const loginData = {
        email: testAdminUser.email,
        password: 'wrongPassword'
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email ou senha inválidos');
    });

    it('should return 400 when non-admin user tries to login as admin', async () => {
      const regularUser = await TestHelpers.createTestUser({
        email: 'regular@example.com',
        username: 'regularuser',
        passhash: bcrypt.hashSync(password, 10),
        role: 'user'
      });

      const loginData = {
        email: regularUser.email,
        password: password
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email ou senha inválidos');
    });

    it('should return 400 when user without role tries to login as admin', async () => {
      const userWithoutRole = await TestHelpers.createTestUser({
        email: 'norole@example.com',
        username: 'noroleuser',
        passhash: bcrypt.hashSync(password, 10)
      });

      const loginData = {
        email: userWithoutRole.email,
        password: password
      };

      const response = await request(app)
        .post('/auth/loginDashboard')
        .send(loginData);

      expect(response.statusCode).toBe(400);
      expect(response.body.message).toBe('Email ou senha inválidos');
    });
  });
});

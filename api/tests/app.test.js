const request = require('supertest')
const app = require('../src/index.js')

describe('GET /ping', () => {
  it('should respond with Pong!', async () => {
    const response = await request(app).get('/ping');
    expect(response.statusCode).toBe(200);
    expect(response.text).toBe('pong');
  });
})

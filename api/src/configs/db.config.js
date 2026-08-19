const env = require('./env.config');

const testConfig = {
  HOST: ':memory:',
  USER: '',
  PASSWORD: '',
  PORT: '',
  DB: '',
  dialect: 'sqlite',
  storage: ':memory:',
  logging: () => { }, // Completely disable SQL logging for tests
  pool: {
    max: 1,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
};

const productionConfig = {
  HOST: 'localhost',
  USER: 'postgres',
  PASSWORD: env.DB_PASSWORD,
  PORT: 5432, // default Postgres port
  DB: 'postgres',
  dialect: 'postgres',
  pool: {
    max: 10,
    min: 0,
    acquire: 30000,
    idle: 10000
  }
};

module.exports = process.env.NODE_ENV === 'test' ? testConfig : productionConfig;

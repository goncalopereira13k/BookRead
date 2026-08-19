const db = require('../src/models');

// Ensure test environment is set
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key-for-testing';

// Global test database setup
beforeAll(async () => {
  try {
    // Sync database before all tests with force to recreate tables
    await db.sequelize.sync({ force: true });
  } catch (error) {
    console.error('Failed to sync test database:', error);
    throw error;
  }
});

// Clean database between tests
beforeEach(async () => {
  try {
    // Clear all tables for a clean state
    // Order matters due to foreign key constraints
    await Promise.all([
      db.booknote.destroy({ truncate: true, force: true }),
      db.readinglog.destroy({ truncate: true, force: true }),
      db.bookstatus.destroy({ truncate: true, force: true }),
      db.settings.destroy({ truncate: true, force: true }),
      db.goal.destroy({ truncate: true, force: true }),
      db.log.destroy({ truncate: true, force: true })
    ]);

    // Clear tables with no dependencies last
    await Promise.all([
      db.user.destroy({ truncate: true, force: true }),
      db.book.destroy({ truncate: true, force: true })
    ]);
  } catch (error) {
    console.error('Failed to clean test database:', error);
  }
});

afterAll(async () => {
  try {
    // Close the database connection after tests
    await db.sequelize.close();
  } catch (error) {
    console.error('Failed to close test database connection:', error);
  }
});
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const db = require('../../src/models');

/**
 * Test helper utilities
 */
class TestHelpers {
  /**
   * Create a test user with hashed password
   */
  static async createTestUser(userData = {}) {
    const defaultUser = {
      email: 'test@example.com',
      username: 'testuser',
      firstName: 'Test',
      lastName: 'User',
      birthdate: '1990-01-01',
      gender: 0,
      passhash: bcrypt.hashSync('password123', 10)
    };

    return await db.user.create({ ...defaultUser, ...userData });
  }

  /**
   * Create an admin user for testing
   */
  static async createAdminUser(userData = {}) {
    const defaultAdmin = {
      email: 'admin@example.com',
      username: 'adminuser',
      firstName: 'Admin',
      lastName: 'User',
      birthdate: '1985-01-01',
      gender: 0,
      role: 'admin',
      passhash: bcrypt.hashSync('adminpassword123', 10)
    };

    return await db.user.create({ ...defaultAdmin, ...userData });
  }

  /**
   * Generate JWT token for a user
   */
  static generateToken(user) {
    return jwt.sign(
      {
        id: user.id,
        email: user.email,
        username: user.username
      },
      process.env.JWT_SECRET || 'test-jwt-secret-key-for-testing',
      { expiresIn: '1h' }
    );
  }

  /**
   * Create a test book with proper format
   */
  static async createTestBook(bookData = {}, userId) {
    const defaultBook = {
      title: 'Test Book',
      subtitle: 'Test Subtitle',
      authors: ['Test Author'],
      pageCount: 300,
      language: 'en',
      publisher: 'Test Publisher',
      categories: ['Fiction'],
      isbn10: '1234567890',
      isbn13: '1234567890123',
      imageUrl: 'http://example.com/image.jpg',
      description: 'Test description'
    };

    if (userId) {
      defaultBook.userId = userId;
    }

    return await db.book.create({ ...defaultBook, ...bookData });
  }

  /**
   * Create a book (alias for createTestBook)
   */
  static async createBook(bookData = {}, userId) {
    return this.createTestBook(bookData, userId);
  }

  /**
   * Create a book status entry
   */
  static async createBookStatus(userId, bookId, status = 1) {
    return await db.bookstatus.create({
      userId,
      bookId,
      status
    });
  }

  /**
   * Create a reading log entry
   */
  static async createReadingLog(userId, bStatusId, data = {}) {
    const defaultData = {
      userId,
      bStatusId,
      pagesReaded: 10,
      duration: 30 * 60 // 30 minutes in seconds
    };

    return await db.readinglog.create({ ...defaultData, ...data });
  }

  /**
   * Create user settings
   */
  static async createSettings(userId, settings = {}) {
    const defaultSettings = {
      userId,
      notifDaily: false,
      notifGoal: false
    };

    return await db.settings.create({ ...defaultSettings, ...settings });
  }

  /**
   * Create a goal
   */
  static async createGoal(userId, goalData = {}) {
    const { GoalType } = require('../../src/models/goal.model');

    const defaultGoal = {
      userId,
      type: GoalType.DAILY,
      value: 10
    };

    // Handle string type conversion
    if (goalData.type === 'daily') {
      goalData.type = GoalType.DAILY;
    } else if (goalData.type === 'yearly') {
      goalData.type = GoalType.YEARLY;
    }

    return await db.goal.create({ ...defaultGoal, ...goalData });
  }

  /**
   * Create a book note
   */
  static async createBookNote(userId, bookId, noteData = {}) {
    const defaultNote = {
      userId,
      bookId,
      content: 'Test note content',
      page: 50
    };

    return await db.booknote.create({ ...defaultNote, ...noteData });
  }

  /**
   * Standard test authentication headers
   */
  static authHeaders(token) {
    return {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    };
  }

  /**
   * Wait for a specific amount of time (for async operations)
   */
  static async wait(ms = 100) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Mock date for consistent testing
   */
  static mockDate(date = '2023-01-15T10:00:00.000Z') {
    const mockedDate = new Date(date);
    jest.useFakeTimers();
    jest.setSystemTime(mockedDate);
    return mockedDate;
  }

  /**
   * Restore real timers
   */
  static restoreTime() {
    jest.useRealTimers();
  }
}

module.exports = TestHelpers;

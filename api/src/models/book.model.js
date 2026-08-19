module.exports = (sequelize, Sequelize) => {
  const Book = sequelize.define('books', {
    id: {
      type: Sequelize.BIGINT,
      primaryKey: true,
      autoIncrement: true,
    },
    apiId: {
      type: Sequelize.STRING,
      unique: true,
      allowNull: true,
    },
    isbn10: {
      type: Sequelize.CHAR(10),
    },
    isbn13: {
      type: Sequelize.CHAR(13),
    },
    title: {
      type: Sequelize.STRING(500),
      allowNull: false,
    },
    subtitle: {
      type: Sequelize.STRING(500),
    },
    authors: {
      type: Sequelize.JSONB,
      validate: {
        isArray(value) {
          if (!Array.isArray(value)) {
            throw new Error('Authors must be an array');
          }
        },
      },
    },
    categories: {
      type: Sequelize.JSONB,
      validate: {
        isArray(value) {
          if (!Array.isArray(value)) {
            throw new Error('Categories must be an array');
          }
        },
      },
    },
    publisher: {
      type: Sequelize.STRING(500),
    },
    pubDate: {
      type: Sequelize.DATEONLY,
    },
    pageCount: {
      type: Sequelize.INTEGER,
    },
    imageUrl: {
      type: Sequelize.STRING(500),
    },
    language: {
      type: Sequelize.STRING,
    },
    description: {
      type: Sequelize.TEXT,
    },
  }, {
    validate: {
      authorsMustBeArray() {
        if (this.authors && !Array.isArray(this.authors)) {
          throw new Error('Authors must be an array');
        }
      },
      categoriesMustBeArray() {
        if (this.categories && !Array.isArray(this.categories)) {
          throw new Error('Categories must be an array');
        }
      },
    },
    freezeTableName: true,
  });

  return Book;
}
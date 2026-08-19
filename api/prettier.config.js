// prettier.config.js, .prettierrc.js, prettier.config.cjs, or .prettierrc.cjs

/**
 * @see https://prettier.io/docs/configuration
 * @type {import("prettier").Config}
 */
const config = {
  semi: true,           // Add semicolons at the end of statements
  quotes: true,         // Single quotes instead of double quotes
  trailingComma: "es5", // Trailing commas where valid in ES5 (objects, arrays, etc.)
  tabWidth: 2,
  semi: false,
  singleQuote: true,
};

module.exports = config;
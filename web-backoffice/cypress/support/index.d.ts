declare namespace Cypress {
  interface Chainable {
    /**
     * Faz login do utilizador via UI.
     * @param email Email do utilizador
     * @param password Password do utilizador
     */
    login(email?: string, password?: string): Chainable<void>;
  }
}

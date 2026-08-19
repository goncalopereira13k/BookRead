// login.cy.ts

describe('Login Page', () => {
  beforeEach(() => {
    cy.visit('http://localhost:3001/login')
  })

  it('should display email and password fields and submit button', () => {
    cy.get('input[name="email"]').should('exist')
    cy.get('input[name="password"]').should('exist')
    cy.get('button[type="submit"]').should('exist')
  })

  it('should show validation errors when submitting empty form', () => {
    cy.get('button[type="submit"]').click()
    cy.contains('Email is required').should('be.visible')
    cy.contains('Password is required').should('be.visible')
  })

  it('should show error for invalid email format', () => {
    cy.get('input[name="email"]').type('invalidemail')
    cy.get('input[name="password"]').type('12345678')
    cy.get('button[type="submit"]').click()
    cy.contains('Email is invalid').should('be.visible')
  })

  it('should show error for empty password', () => {
    cy.get('input[name="email"]').type('a@mail.pt')
    cy.get('button[type="submit"]').click()
    cy.contains('Password is required').should('be.visible')
  })

  it('should login successfully with correct credentials', () => {
    cy.get('input[name="email"]').type('a@mail.pt')
    cy.get('input[name="password"]').type('12345678')
    cy.get('button[type="submit"]').click()
    cy.url().should('not.include', '/login')
    // ou checar algum elemento da página principal
  })

  it('should show error with incorrect credentials', () => {
    cy.get('input[name="email"]').type('wrong@mail.pt')
    cy.get('input[name="password"]').type('wrongpass')
    cy.get('button[type="submit"]').click()
    
  })
})
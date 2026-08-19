describe('Página Principal', () => {
  beforeEach(() => {
    cy.login() // Login via comando customizado
    cy.visit('/')
  })

  it('deve mostrar os cards de resumo com títulos e valores', () => {
    const cards = [
      'Utilizadores',
      'Livros',
      'Leituras feitas hoje',
      'Notas realizadas no dia'
    ]

    cards.forEach((title) => {
      cy.contains('.card', title).within(() => {
        cy.get('span.fs-3').should('exist')
      })
    })
  })

  it('deve mostrar o gráfico de leituras', () => {
    cy.contains('.card', 'Leituras realizadas').within(() => {
      cy.get('canvas, svg').should('exist')
    })
  })

  it('deve mostrar logs recentes no componente LogsCard', () => {
    cy.contains('.card', 'Logs').should('be.visible')
    cy.contains('.card', 'Logs').within(() => {
      cy.get('.list-group-item').should('exist')
    })
  })

  it('deve mostrar a navbar e sidebar fixas', () => {
    cy.get('nav').should('exist').and('be.visible')
    cy.get('.sidebar').should('exist').and('be.visible')
  })

  it('deve fazer logout corretamente ao clicar no dropdown', () => {
    // Garante token
    cy.window().then((win) => {
      win.localStorage.setItem('token', 'fake-jwt-token')
    })

    // Abre dropdown e faz logout
    cy.get('#dropdown-user').click()
    cy.contains('Sair').click()

    // Confirma redirecionamento
    cy.url().should('include', '/login')

    // Token foi removido
    cy.window().then((win) => {
      expect(win.localStorage.getItem('token')).to.be.null
    })
  })
})

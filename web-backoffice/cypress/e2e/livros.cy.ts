describe('Página de Livros', () => {
  beforeEach(() => {
    cy.login(); // Usa comando customizado de login
    cy.visit('/livros');
  });

  it('deve mostrar o título da página', () => {
    cy.contains('Livros Populares').should('be.visible');
  });

  it('deve mostrar uma lista de livros', () => {
    cy.get('.book-card').should('have.length.at.least', 1);
    cy.get('.book-card').first().within(() => {
      cy.get('img').should('exist');
      cy.get('.book-title').should('exist');
    });
  });

  it('deve navegar para o detalhe do primeiro livro e voltar', () => {
    cy.get('.book-card').first().click();
    cy.url().should('match', /\/livros\//);
    cy.get('.book-detail-page').should('exist');
    cy.contains('Voltar à lista').click();
    cy.url().should('include', '/livros');
    cy.get('.books-title').should('be.visible');
  });

  it('deve paginar os livros se houver mais de uma página', () => {
    cy.get('.pagination').then($pagination => {
      if ($pagination.find('.page-btn').length > 1) {
        cy.get('.page-btn').eq(1).click();
        cy.get('.book-card').should('exist');
        cy.get('.page-btn.active').should('contain', '2');
      }
    });
  });

  it('deve voltar à página principal ao clicar no botão de voltar', () => {
    cy.contains('button', 'Voltar à Página Principal').click();
    cy.url().should('eq', Cypress.config().baseUrl + '/');
  });
});

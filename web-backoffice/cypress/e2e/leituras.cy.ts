describe('Página de Leituras', () => {
  beforeEach(() => {
    cy.login(); // Usa comando customizado de login
    cy.visit('/leituras');
  });

  it('deve mostrar o card de leituras de hoje', () => {
    cy.contains('Leituras de Hoje').should('be.visible');
    cy.contains('Leituras de Hoje')
      .parent()
      .find('.fs-3')
      .should('exist');
  });

  it('deve mostrar a tabela de leituras com colunas principais', () => {
    cy.get('table').should('exist');
    cy.get('thead').within(() => {
      cy.contains('Data').should('exist');
      cy.contains('Total de Leituras').should('exist');
    });
  });

  it('deve filtrar leituras pelo campo de pesquisa', () => {
    cy.get('input[placeholder*="Pesquisar por data"]').as('searchInput');
    cy.get('tbody tr').then(rows => {
      if (rows.length > 1) {
        const firstDate = rows[0].children[0].textContent;
        cy.get('@searchInput').type(firstDate || '');
        cy.get('tbody tr').should('have.length.at.least', 1);
        cy.get('tbody tr').first().contains(firstDate || '');
      }
    });
  });

  it('deve mostrar mensagem se nenhuma leitura for encontrada', () => {
    cy.get('input[placeholder*="Pesquisar por data"]').clear().type('2099-01-01');
    cy.contains('Nenhuma leitura encontrada.').should('be.visible');
  });

  it('deve voltar à página principal ao clicar no botão Voltar', () => {
    cy.contains('button', 'Voltar').click();
    cy.url().should('eq', Cypress.config().baseUrl + '/');
  });
});

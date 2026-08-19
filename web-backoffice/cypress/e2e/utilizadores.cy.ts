describe('Página de Utilizadores', () => {
  beforeEach(() => {
    cy.login(); // Usa comando customizado de login
    cy.visit('/utilizadores');
  });

  it('deve mostrar o total de utilizadores', () => {
    cy.contains('Total de Utilizadores').should('be.visible');
    cy.contains('Total de Utilizadores')
      .parent()
      .find('.fs-3')
      .should('exist');
  });

  it('deve mostrar a tabela de utilizadores com colunas principais', () => {
    cy.get('table').should('exist');
    cy.get('thead').within(() => {
      cy.contains('Username').should('exist');
      cy.contains('Email').should('exist');
      cy.contains('Género').should('exist');
      cy.contains('Data de Registo').should('exist');
      cy.contains('Ações').should('exist');
    });
  });

  it('deve filtrar utilizadores pelo campo de pesquisa', () => {
    cy.get('input[placeholder*="Pesquisar utilizadores"]').as('searchInput');
    cy.get('tbody tr').then(rows => {
      if (rows.length > 1) {
        const firstUser = rows[0].children[0].textContent;
        cy.get('@searchInput').type(firstUser || '');
        cy.get('tbody tr').should('have.length.at.least', 1);
        cy.get('tbody tr').first().contains(firstUser || '');
      }
    });
  });

  it('deve mostrar mensagem se nenhum utilizador for encontrado', () => {
    cy.get('input[placeholder*="Pesquisar utilizadores"]').clear().type('utilizadorinexistente123');
    cy.contains('Nenhum utilizador encontrado.').should('be.visible');
  });

  it('deve ter botões Ver e Editar para cada utilizador', () => {
    cy.get('tbody tr').each(($row) => {
      if (!$row.text().includes('Nenhum utilizador encontrado.')) {
        cy.wrap($row).find('button').contains('Ver').should('exist');
        cy.wrap($row).find('button').contains('Editar').should('exist');
      }
    });
  });

  it('deve voltar à página principal ao clicar no botão Voltar', () => {
    cy.contains('button', 'Voltar').click();
    cy.url().should('eq', Cypress.config().baseUrl + '/');
  });
});

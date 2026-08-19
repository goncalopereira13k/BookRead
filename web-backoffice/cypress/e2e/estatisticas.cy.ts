describe('Página de Estatísticas', () => {
  beforeEach(() => {
    cy.login();
    cy.visit('/estatisticas');
  });

  it('deve mostrar o título e os cards de estatísticas', () => {
    cy.contains('Estatísticas').should('be.visible');
    cy.get('.stat-card').should('have.length', 4);
    cy.contains('.stat-card', 'Utilizadores').should('exist');
    cy.contains('.stat-card', 'Livros').should('exist');
    cy.contains('.stat-card', 'Leituras Hoje').should('exist');
    cy.contains('.stat-card', 'Notas Hoje').should('exist');
  });

  it('deve mostrar o gráfico de Leituras e mudar o range', () => {
    cy.contains('Leituras').should('be.visible');
    cy.get('.chart-section').first().within(() => {
      cy.get('svg').should('exist');
      cy.get('select').select('Últimos 15 dias');
      cy.get('svg').should('exist');
      cy.get('select').select('Último mês');
      cy.get('svg').should('exist');
    });
  });

  it('deve mostrar o gráfico de Notas e mudar o range', () => {
    cy.contains('Notas').should('be.visible');
    cy.get('.chart-section').eq(1).within(() => {
      cy.get('svg').should('exist');
      cy.get('select').select('Últimos 15 dias');
      cy.get('svg').should('exist');
      cy.get('select').select('Último mês');
      cy.get('svg').should('exist');
    });
  });

  it('deve mostrar o gráfico de Registos de Utilizadores e mudar o range', () => {
    cy.contains('Registos de Utilizadores').should('be.visible');
    cy.get('.chart-section').eq(2).within(() => {
      cy.get('svg').should('exist');
      cy.get('select').select('Últimos 15 dias');
      cy.get('svg').should('exist');
      cy.get('select').select('Último mês');
      cy.get('svg').should('exist');
    });
  });

  it('deve mostrar o gráfico de Livros adicionados e mudar o range', () => {
    cy.contains('Livros adicionados').should('be.visible');
    cy.get('.chart-section').eq(3).within(() => {
      cy.get('svg').should('exist');
      cy.get('select').select('Últimos 15 dias');
      cy.get('svg').should('exist');
      cy.get('select').select('Último mês');
      cy.get('svg').should('exist');
    });
  });

  it('deve voltar atrás ao clicar no botão de voltar', () => {
    cy.get('.back-button').click();
    cy.url().should('not.include', '/estatisticas');
  });
});

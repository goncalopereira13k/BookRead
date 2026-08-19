describe('Perfil Page', () => {
  beforeEach(() => {
    cy.login() // Login antes de cada teste
    cy.visit('/perfil') // Usando baseUrl
  })

  it('deve mostrar as informações do perfil', () => {
    cy.contains('Username:').should('be.visible')
    cy.contains('Email:').should('be.visible')
    cy.contains('Data de nascimento:').should('be.visible')
    cy.contains('Género:').should('be.visible')
  })

  it('deve exibir elementos do perfil', () => {
    cy.get('.perfil-nome').should('exist')
    cy.get('.perfil-info').should('contain', 'Username:')
    cy.get('.perfil-info').should('contain', 'Email:')
    cy.get('.perfil-info').should('contain', 'Data de nascimento:')
    cy.get('.perfil-info').should('contain', 'Género:')
    cy.contains('button', 'Editar Perfil').should('exist')
    cy.contains('button', 'Voltar').should('exist')
  })

  it('deve abrir o formulário de edição ao clicar em "Editar Perfil"', () => {
    cy.contains('button', 'Editar Perfil').click()
    cy.get('form.perfil-form').should('exist')
    cy.get('input[name="username"]').should('exist')
    cy.get('input[name="email"]').should('exist')
    cy.get('input[name="birthdate"]').should('exist')
    cy.get('select[name="gender"]').should('exist')
    cy.contains('button[type="submit"]', 'Guardar').should('exist')
    cy.contains('button', 'Cancelar').should('exist')
  })

  it('deve validar campos obrigatórios', () => {
    cy.contains('button', 'Editar Perfil').click()
    cy.get('input[name="username"]').clear()
    cy.get('input[name="email"]').clear()
    cy.get('input[name="birthdate"]').clear()
    cy.get('button[type="submit"]').click()

    cy.get('input[name="username"]:invalid').should('exist')
    cy.get('input[name="email"]:invalid').should('exist')
    cy.get('input[name="birthdate"]:invalid').should('exist')
  })

  it('deve validar formato de email', () => {
    cy.contains('button', 'Editar Perfil').click()
    cy.get('input[name="email"]').clear().type('emailinvalido')
    cy.get('button[type="submit"]').click()
    cy.get('input[name="email"]:invalid').should('exist')
  })

  it('deve atualizar perfil com dados válidos', () => {
    cy.contains('button', 'Editar Perfil').click()
    cy.get('input[name="username"]').clear().type('NovoNome')
    cy.get('input[name="email"]').clear().type('novo@email.com')
    cy.get('input[name="birthdate"]').clear().type('2000-01-01')
    cy.get('select[name="gender"]').select('Masculino')
    cy.get('button[type="submit"]').contains('Guardar').click()

    cy.get('.perfil-nome').should('contain', 'NovoNome')
    cy.get('.perfil-info').should('contain', 'novo@email.com')
  })

  

})

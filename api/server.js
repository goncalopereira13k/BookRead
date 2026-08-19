const cors = require('cors')
const app = require('./src/index.js')
const port = process.env.PORT || '3000'

var corsOptions = {
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}

app.use(cors(corsOptions))

app.listen(port, () => {
  console.log(`Listening on port ${port}`)
})
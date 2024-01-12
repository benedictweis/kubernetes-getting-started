const express = require('express')
const app = express()
const port = process.env.PORT || 3000

app.get('/hello', (req, res) => {
  res.send(randomWord())
})

app.listen(port, '0.0.0.0', () => {
  console.log(`Hello app backend listening on port ${port}`)
})

const words = ["hi", "willkommen", "schnitzel"]

function randomWord() {
  return words[Math.floor(Math.random() * words.length)]
}
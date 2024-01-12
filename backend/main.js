const express = require('express')
const app = express()
const port = process.env.PORT || 3000
const wordsString = process.env.WORDS || "hi,willkommen,schnitzel"

app.get('/hello', (req, res) => {
  res.send(randomWord())
})

app.listen(port, '0.0.0.0', () => {
  console.log(`Hello app backend listening on port ${port}`)
})

const words = wordsString.split(",")

function randomWord() {
  return words[Math.floor(Math.random() * words.length)]
}
const express = require('express')
const app = express()
const port = process.env.PORT || 80
const service_port = process.env.SERVICE_PORT || 3000
const service_hostname = process.env.SERVICE_HOSTNAME || `word-app-service`
const welcome_message = process.env.WELCOME_MESSAGE || `Hello, your random word:`

const page=`
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
    <title>Hello-App</title>
</head>
<body>
    <main class="container">
        <h1>${welcome_message}</h1>
        <article>{{WORD}}</article>
    </main>
</body>
</html>
`

app.get('/', async(req, res) =>  {
    const serviceResponse = await fetch(`http://${service_hostname}:${service_port}/hello`)
    const word = await serviceResponse.text();
    res.send(page.replace("{{WORD}}", word))
})

app.listen(port, '0.0.0.0', () => {
    console.log(`Hello app frontend listening on port ${port}`)
})
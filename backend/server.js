const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// read endpoint from environment variables
const endpoint = 'process.env.ENDPOINT';

// read subscription key from local .secretsfile
// first, read the local file
const fs = require('fs');
const secrets = fs.readFileSync('.secretsfile', 'utf8');
// the first line contains the plain text subscription key
const subscriptionKey = secrets

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const corsOptions = {
  origin: ['https://summarize.amtmann.de', 'http://localhost:4200', 'http://localhost:80'],
  optionsSuccessStatus: 200,
};

app.use(cors(corsOptions));

app.post('/summarize', async (req, res) => {
  console.log('Received a request to summarize text');
  const textToSummarize = req.body.text;
  
  if (!textToSummarize) {
    console.log('Bad request: Missing text');
    return res.status(400).json({ error: 'Text is required' });
  }

  console.log('Text to summarize:', textToSummarize);

  try {
    const summarizationResult = await getSummaryFromAzure(textToSummarize);
    console.log('Summarization result:', summarizationResult);
    res.json(summarizationResult);
  } catch (error) {
    console.error('Error during summarization:', error.message);
    res.status(500).json({ error: error.message });
  }
});

async function getSummaryFromAzure(text) {
  const url = `${endpoint}/text/analytics/v3.2-preview.1/summarize`;

  const data = {
    documents: [
      {
        language: 'en',
        id: '1',
        text: text,
      },
    ],
  };

  const headers = {
    'Content-Type': 'application/json',
    'Ocp-Apim-Subscription-Key': subscriptionKey,
  };

  console.log('Sending request to Azure Text Analytics API');
  const response = await axios.post(url, data, { headers });
  const summary = response.data.documents[0].sentences;
  console.log('Received summary from Azure Text Analytics API:', summary);
  return { summary };
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

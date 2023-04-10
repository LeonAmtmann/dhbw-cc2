const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { AzureKeyCredential, TextAnalysisClient } = require('@azure/ai-language-text');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// read endpoint and apiKey from environment variables
const endpoint = process.env.ENDPOINT;
const apiKey = process.env.LANGUAGE_API_KEY;

//print endpoint and apiKey to console
console.log('endpoint: ', endpoint);
console.log('apiKey: ', apiKey);

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
  const length = parseInt(req.body.length);

  // guards
  if (!textToSummarize) {
    console.log('Bad request: Missing text');
    return res.status(400).json({ error: 'Text is required' });
  }

  if (isNaN(length)) {
    console.log('Bad request: Invalid length');
    return res.status(400).json({ error: 'Length must be a number' });
  }

  console.log('Text to summarize:', textToSummarize);

  try {
    const summarizationResult = await getSummaryFromAzure(textToSummarize, length);
    console.log('Summarization result:', summarizationResult);
    const result = { summary: summarizationResult };
    res.json(result);
  } catch (error) {
    console.error('Error during summarization:', error.message);
    res.status(500).json({ error: error.message });
  }
});

async function getSummaryFromAzure(text, length) {
  const client = new TextAnalysisClient(endpoint, new AzureKeyCredential(apiKey));
  const actions = [
    {
      kind: 'ExtractiveSummarization',
      maxSentenceCount: length || 3,
    },
  ];
  const poller = await client.beginAnalyzeBatch(actions, [text]);

  const results = await poller.pollUntilDone();

  let summary = '';
  for await (const actionResult of results) {
    if (actionResult.kind !== 'ExtractiveSummarization') {
      throw new Error(`Expected extractive summarization results but got: ${actionResult.kind}`);
    }
    if (actionResult.error) {
      const { code, message } = actionResult.error;
      throw new Error(`Unexpected error (${code}): ${message}`);
    }
    for (const result of actionResult.results) {
      summary = result.sentences.map((sentence) => sentence.text).join('\n');
    }
  }
  return summary;
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

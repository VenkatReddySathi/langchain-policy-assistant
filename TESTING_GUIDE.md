# Testing Guide for LangChain Policy Assistant

## Prerequisites Before Testing

### 1. Create `.env` file
Create a `.env` file in the root directory with your OpenAI API key:
```
OPENAI_API_KEY=your_openai_api_key_here
CHAT_MODEL=gpt-4o-mini
EMB_MODEL=text-embedding-3-small
```

### 2. Add Policy Documents
Place your policy text files (`.txt` format) in the `data/policies/` directory.

### 3. Create Vectorstore Index
Run the ingestion script to create the searchable index:
```bash
python -m app.rag.ingest
```

### 4. Start the Server
```bash
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

## Testing Methods

### Method 1: Using FastAPI Interactive Docs (Easiest)
1. Open browser: `http://127.0.0.1:8000/docs`
2. Click on `POST /ask` endpoint
3. Click "Try it out"
4. Enter your question in the request body:
   ```json
   {
     "question": "How many casual leaves?",
     "prompt_version": "v2",
     "top_k": 5
   }
   ```
5. Click "Execute"

### Method 2: Using PowerShell (Windows)
```powershell
$body = @{
    question = "How many casual leaves?"
    prompt_version = "v2"
    top_k = 5
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://127.0.0.1:8000/ask" -Method POST -Body $body -ContentType "application/json"
```

### Method 3: Using curl.exe (Windows)
```bash
curl.exe -X POST http://127.0.0.1:8000/ask -H "Content-Type: application/json" -d "{\"question\":\"How many casual leaves?\",\"prompt_version\":\"v2\",\"top_k\":5}"
```

### Method 4: Using Python requests
```python
import requests

response = requests.post(
    "http://127.0.0.1:8000/ask",
    json={
        "question": "How many casual leaves?",
        "prompt_version": "v2",
        "top_k": 5
    }
)
print(response.json())
```

## Expected Response
```json
{
  "answer": {
    "answer": "Based on the policy...",
    "citations": ["policy_file.txt#chunk=0"],
    "confidence": 0.85
  },
  "prompt_version": "v2",
  "route": "policy_qa",
  "retrieved_chunks": 5,
  "debug": {
    "raw_preview": "..."
  }
}
```

## Troubleshooting

### Error: "Index directory not found"
- Run: `python -m app.rag.ingest` to create the index

### Error: "OPENAI_API_KEY not set"
- Create `.env` file with your API key

### Error: "No documents found to ingest"
- Add `.txt` files to `data/policies/` directory

### Error: "Internal Server Error"
- Check server logs for detailed error messages
- Ensure all prerequisites are met


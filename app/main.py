# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.api.routes import router as api_router


def create_app() -> FastAPI:
    app = FastAPI(title=settings.APP_NAME)

    # Add CORS middleware to allow browser access
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # Allows all origins
        allow_credentials=True,
        allow_methods=["*"],  # Allows all methods
        allow_headers=["*"],  # Allows all headers
    )

    # Root route
    @app.get("/")
    def root():
        return {
            "message": "LangChain Policy Assistant API",
            "version": "1.0.0",
            "description": "This is a backend API for querying company policies using RAG (Retrieval Augmented Generation)",
            "quick_start": "Visit /docs for interactive API documentation",
            "endpoints": {
                "health": "/health (GET) - Health check endpoint",
                "ask": "/ask (POST) - Ask policy questions. Requires: {question: string, prompt_version?: string, top_k?: number}",
                "docs": "/docs - Interactive API documentation (Swagger UI) - RECOMMENDED",
                "openapi": "/openapi.json - OpenAPI schema"
            },
            "example_request": {
                "url": "/ask",
                "method": "POST",
                "body": {
                    "question": "What is the leave policy?",
                    "prompt_version": "v2",
                    "top_k": 5
                }
            }
        }

    app.include_router(api_router)
    return app


app = create_app()

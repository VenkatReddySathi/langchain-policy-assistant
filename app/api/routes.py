# app/api/routes.py
from fastapi import APIRouter
from app.schemas.request import AskRequest
from app.schemas.response import AskResponse
from app.chains.router_chain import route_and_run
from app.telemetry.logger import log_event

router = APIRouter()


@router.get("/health")
def health():
    return {"status": "ok"}


@router.post("/ask", response_model=AskResponse)
def ask(req: AskRequest):
    log_event("ask_request", {
              "prompt_version": req.prompt_version, "top_k": req.top_k})
    return route_and_run(req)

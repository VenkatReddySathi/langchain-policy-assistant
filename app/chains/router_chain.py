# app/chains/router_chain.py
import json
from langchain_core.prompts import PromptTemplate

from app.config import settings
from app.dependencies import chat_model
from app.prompts import load_prompt_file
from app.schemas.request import AskRequest
from app.schemas.response import AskResponse, PolicyAnswer
from app.chains.rag_chain import build_rag_chain


def route_question(question: str) -> str:
    txt = load_prompt_file(f"router_{settings.ROUTER_VERSION}.txt")
    prompt = PromptTemplate.from_template(txt).format(question=question)
    raw = chat_model().invoke(prompt).content
    try:
        obj = json.loads(raw)
        return obj.get("route", "policy_qa")
    except Exception:
        return "policy_qa"


def route_and_run(req: AskRequest) -> AskResponse:
    route = route_question(req.question)

    if route == "smalltalk":
        ans = PolicyAnswer(
            answer="I can help with company policy questions. Please ask your policy query.",
            citations=[],
            confidence=0.5
        )
        return AskResponse(answer=ans, prompt_version=req.prompt_version, route=route, retrieved_chunks=0)

    chain = build_rag_chain(prompt_version=req.prompt_version)
    out = chain.invoke({"question": req.question, "top_k": req.top_k})

    parsed = out["parsed"]
    if not parsed.get("citations"):
        parsed["citations"] = out.get("citations", [])[:2]

    return AskResponse(
        answer=PolicyAnswer(**parsed),
        prompt_version=req.prompt_version,
        route=route,
        retrieved_chunks=out.get("retrieved_chunks", 0),
        debug={"raw_preview": out.get("raw", "")[:200]}
    )

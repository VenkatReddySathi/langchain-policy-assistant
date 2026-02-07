# app/chains/rag_chain.py
from typing import Dict, Any
from langchain_core.runnables import RunnablePassthrough
from langchain_core.prompts import PromptTemplate

from app.config import settings
from app.dependencies import vectorstore, chat_model
from app.llm.parsers import policy_answer_parser
from app.prompts import load_prompt_file
from app.rag.sanitize import sanitize_chunks
from app.utils.text import clamp_text


def build_rag_chain(prompt_version: str = "v2"):
    parser = policy_answer_parser()
    prompt_txt = load_prompt_file(f"policy_qa_{prompt_version}.txt")
    prompt = PromptTemplate.from_template(prompt_txt)

    def retrieve(inputs: Dict[str, Any]) -> Dict[str, Any]:
        q = inputs["question"]
        k = inputs.get("top_k", settings.DEFAULT_TOP_K)

        docs = vectorstore().similarity_search(q, k=k)
        raw_chunks = [d.page_content for d in docs]
        chunks = sanitize_chunks(raw_chunks)

        citations = [
            f"{d.metadata.get('source')}#chunk={d.metadata.get('chunk_id')}" for d in docs]
        context = "\n\n".join(
            [f"[{citations[i]}]\n{chunks[i]}" for i in range(len(chunks))]
        )
        context = clamp_text(context, settings.MAX_CONTEXT_CHARS)

        return {"question": q, "context": context, "citations": citations, "retrieved_chunks": len(docs)}

    chain = (
        RunnablePassthrough()
        | retrieve
        | (lambda x: {**x, "prompt": prompt.format(question=x["question"], context=x["context"])})
        | (lambda x: {**x, "raw": chat_model().invoke(x["prompt"]).content})
        | (lambda x: {**x, "parsed": parser.parse(x["raw"])})
    )

    return chain

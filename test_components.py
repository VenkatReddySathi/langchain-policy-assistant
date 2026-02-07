"""Test script to identify which component is failing"""
import traceback
from app.config import settings
from app.schemas.request import AskRequest

print("=" * 50)
print("Testing Components")
print("=" * 50)

# Test 1: Configuration
print("\n1. Testing Configuration...")
try:
    print(f"   [OK] OPENAI_API_KEY: {'Set' if settings.OPENAI_API_KEY else 'NOT SET'}")
    print(f"   [OK] CHAT_MODEL: {settings.CHAT_MODEL}")
    print(f"   [OK] EMB_MODEL: {settings.EMB_MODEL}")
    print(f"   [OK] INDEX_DIR: {settings.INDEX_DIR}")
except Exception as e:
    print(f"   [ERROR] Error: {e}")
    traceback.print_exc()

# Test 2: Vectorstore
print("\n2. Testing Vectorstore...")
try:
    from app.dependencies import vectorstore
    vs = vectorstore()
    print(f"   [OK] Vectorstore loaded successfully")
except Exception as e:
    print(f"   [ERROR] Error loading vectorstore: {e}")
    traceback.print_exc()

# Test 3: Chat Model
print("\n3. Testing Chat Model...")
try:
    from app.dependencies import chat_model
    cm = chat_model()
    print(f"   [OK] Chat model created: {cm.model_name}")
except Exception as e:
    print(f"   [ERROR] Error creating chat model: {e}")
    traceback.print_exc()

# Test 4: RAG Chain
print("\n4. Testing RAG Chain...")
try:
    from app.chains.rag_chain import build_rag_chain
    chain = build_rag_chain("v2")
    print(f"   [OK] RAG chain built successfully")
except Exception as e:
    print(f"   [ERROR] Error building RAG chain: {e}")
    traceback.print_exc()

# Test 5: Full Request
print("\n5. Testing Full Request Flow...")
try:
    from app.chains.router_chain import route_and_run
    req = AskRequest(question="How many casual leaves?", prompt_version="v2", top_k=5)
    print(f"   Request created: {req.question}")
    print("   Processing request...")
    response = route_and_run(req)
    print(f"   [OK] Request successful!")
    print(f"   Answer: {response.answer.answer[:100]}...")
except Exception as e:
    print(f"   [ERROR] Error processing request: {e}")
    traceback.print_exc()

print("\n" + "=" * 50)
print("Testing Complete")
print("=" * 50)


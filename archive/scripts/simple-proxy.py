#!/usr/bin/env python3
"""
Simple proxy to strip non-standard OpenAI fields from vLLM responses.
Fixes GitHub Copilot compatibility issues.
"""
import json
import requests
from flask import Flask, request, jsonify
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

# Your vLLM backend
VLLM_BASE = "http://localhost:8000/v1"
VLLM_API_KEY = "sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9"

# Fields that break Copilot (will be removed from responses)
FIELDS_TO_REMOVE = {'reasoning', 'reasoning_content', 'annotations', 'audio', 'refusal'}

def clean_message(message):
    """Remove non-standard fields from a message object."""
    return {k: v for k, v in message.items() if k not in FIELDS_TO_REMOVE}

def clean_response(data):
    """Clean all messages in the response."""
    if 'choices' in data:
        for choice in data['choices']:
            if 'message' in choice:
                choice['message'] = clean_message(choice['message'])
    return data

@app.route('/v1/models', methods=['GET'])
def models():
    """Proxy models endpoint."""
    headers = {'Authorization': request.headers.get('Authorization', f'Bearer {VLLM_API_KEY}')}
    response = requests.get(f"{VLLM_BASE}/models", headers=headers)
    return jsonify(response.json()), response.status_code

@app.route('/v1/chat/completions', methods=['POST'])
def chat_completions():
    """Proxy chat completions and strip problematic fields."""
    try:
        # Forward request to vLLM
        headers = {
            'Authorization': request.headers.get('Authorization', f'Bearer {VLLM_API_KEY}'),
            'Content-Type': 'application/json'
        }

        response = requests.post(
            f"{VLLM_BASE}/chat/completions",
            headers=headers,
            json=request.json,
            timeout=600
        )

        # Clean the response
        data = response.json()
        cleaned = clean_response(data)

        logging.info(f"Cleaned response - removed fields: {FIELDS_TO_REMOVE}")
        return jsonify(cleaned), response.status_code

    except Exception as e:
        logging.error(f"Error: {e}")
        return jsonify({"error": str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({"status": "ok", "proxy": "simple-copilot-fix"}), 200

if __name__ == '__main__':
    print("🚀 Starting simple proxy on port 4000...")
    print(f"📡 Forwarding to: {VLLM_BASE}")
    print(f"🧹 Stripping fields: {FIELDS_TO_REMOVE}")
    print(f"🔑 Using API key: {VLLM_API_KEY[:20]}...")
    app.run(host='0.0.0.0', port=4000, debug=False)

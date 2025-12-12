#!/bin/bash
# Dead simple proxy - strips the BS fields that break Copilot
# Run this on RunPod, point Copilot at port 4000, done.

pip install flask requests

cat > /workspace/proxy.py << 'EOF'
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
BACKEND = "http://localhost:8000/v1"
KEY = "sk-vllm-4621df5fb0a1f78adbe91ff2fbca9cd9"
BAD_FIELDS = {'reasoning', 'reasoning_content', 'annotations', 'audio', 'refusal'}

@app.route('/v1/<path:path>', methods=['GET', 'POST'])
def proxy(path):
    url = f"{BACKEND}/{path}"
    headers = {'Authorization': request.headers.get('Authorization', f'Bearer {KEY}')}

    if request.method == 'POST':
        resp = requests.post(url, headers=headers, json=request.json, timeout=600)
    else:
        resp = requests.get(url, headers=headers)

    data = resp.json()

    # Strip the BS fields
    if 'choices' in data:
        for choice in data['choices']:
            if 'message' in choice:
                for field in BAD_FIELDS:
                    choice['message'].pop(field, None)

    return jsonify(data), resp.status_code

if __name__ == '__main__':
    print("Proxy running on 4000, stripping BS fields")
    app.run(host='0.0.0.0', port=4000)
EOF

echo "Run: python3 /workspace/proxy.py"

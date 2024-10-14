import os
import json
import requests

TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")

CHAT_ID = "-1002428644828"
API_URL = f"http://localhost:8081/bot{TELEGRAM_BOT_TOKEN}/sendMediaGroup"

DIST_DIR = os.path.join(os.getcwd(), "dist")
release_file = os.path.join(os.getcwd(), "release.md")

media = []
curl_files = {}

i = 1
for file in os.listdir(DIST_DIR):
    file_path = os.path.join(DIST_DIR, file)
    if os.path.isfile(file_path):
        file_key = f"file{i}"
        media.append({
            "type": "document",
            "media": f"attach://{file_key}"
        })
        curl_files[file_key] = open(file_path, 'rb')
        i += 1

with open(release_file, 'r') as f:
    release_notes = f.read()

if media:
    media[-1]["caption"] = release_notes
#     media[-1]["parse_mode"] = "MarkdownV2"

response = requests.post(
    API_URL,
    data={
        "chat_id": CHAT_ID,
        "media": json.dumps(media)
    },
    files=curl_files
)

print("Response JSON:", response.json())
import json

from flask import Flask, request

app = Flask(__name__)


@app.route("/orders", methods=["POST"])
def getOrder() -> tuple[str, int, dict[str, str]]:
    # Tell Basedpyright to look the other way on 'Any' for this specific line
    data = request.json  # pyright: ignore [reportAny]
    print("Order received : " + json.dumps(data), flush=True)
    return json.dumps({"success": True}), 200, {"ContentType": "application/json"}


app.run(port=8001)

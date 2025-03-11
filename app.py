from flask import Flask, send_from_directory, render_template
import os
import sys

# Create Flask app
app = Flask(__name__)

@app.route('/<path:path>')
def catch_all(path):
    print(f"Caught path: {path}", file=sys.stderr)
    print(f"Full URL: {request.url}", file=sys.stderr)
    print(f"Method: {request.method}", file=sys.stderr)
    print(f"Headers: {dict(request.headers)}", file=sys.stderr)
    return render_template("index.html")
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888, debug=True)

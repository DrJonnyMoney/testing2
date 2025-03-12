from flask import Flask, send_from_directory, render_template, request
import os
import sys
base_prefix = os.environ.get('NB_PREFIX', '')
print('URL@' + base_prefix)
# Create Flask app
app = Flask(__name__)

@app.route(base_prefix + '/')
def index():
    return render_template("index.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888, debug=True)

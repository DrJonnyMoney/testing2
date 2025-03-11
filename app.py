from flask import Flask, send_from_directory, render_template, request
import os

# Get base prefix from environment or default to empty string
base_prefix = os.environ.get('JUPYTER_SERVICE_PREFIX', '')

app = Flask(__name__, 
            static_folder="static",
            template_folder="templates")

@app.route("/")
@app.route(base_prefix + "/")
def index():
    return render_template("index.html")

@app.route("/static/<path:path>")
@app.route(base_prefix + "/static/<path:path>")
def serve_static(path):
    return send_from_directory("static", path)

# Add a catch-all route to handle Kubeflow's proxied requests
@app.route('/<path:path>')
def catch_all(path):
    # Try to serve from static first
    if path.startswith('static/'):
        return send_from_directory(".", path)
    # Otherwise try to render as a template
    try:
        return render_template(path)
    except:
        # If all else fails, show the index page
        return render_template("index.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8888)

from flask import Flask, send_from_directory, render_template
import os
import sys

# Detailed debugging function
def debug_static_files():
    # Get current script directory
    current_dir = os.path.dirname(os.path.abspath(__file__))
    print("Current Directory:", current_dir)
    
    # Potential static file locations
    potential_static_dirs = [
        os.path.join(current_dir, 'static'),
        os.path.join(current_dir, 'staticfiles'),
        current_dir
    ]
    
    print("\nPotential Static File Directories:")
    for static_dir in potential_static_dirs:
        print(f"\nChecking directory: {static_dir}")
        if os.path.exists(static_dir):
            print("Directory exists. Contents:")
            try:
                contents = os.listdir(static_dir)
                for item in contents:
                    full_path = os.path.join(static_dir, item)
                    print(f"- {item} (Type: {'Directory' if os.path.isdir(full_path) else 'File'})")
            except Exception as e:
                print(f"Error listing directory: {e}")
        else:
            print("Directory does not exist")
    
    # Print Python path
    print("\nPython Path:")
    for path in sys.path:
        print(path)

# Get base prefix from environment
base_prefix = os.environ.get('JUPYTER_SERVICE_PREFIX', '')
print(f"Base Prefix: '{base_prefix}'")

# Run debugging
debug_static_files()

# Create Flask app
app = Flask(__name__, 
            static_folder='static',  # Explicitly set static folder
            template_folder='templates')

# Debug route for static files
@app.route('/static/<path:filename>')
def custom_static(filename):
    print(f"Requested static file: {filename}")
    try:
        # Attempt to serve from multiple potential directories
        current_dir = os.path.dirname(os.path.abspath(__file__))
        potential_dirs = [
            os.path.join(current_dir, 'static'),
            current_dir
        ]
        
        for directory in potential_dirs:
            full_path = os.path.join(directory, filename)
            print(f"Checking path: {full_path}")
            if os.path.exists(full_path):
                print(f"Serving file from: {directory}")
                return send_from_directory(directory, filename)
        
        print(f"File not found: {filename}")
        return "File not found", 404
    except Exception as e:
        print(f"Error serving static file: {e}")
        return str(e), 500

# Main routes
@app.route('/')
@app.route(base_prefix + '/')
def index():
    return render_template('index.html')
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
    app.run(host="0.0.0.0", port=8888, debug=True)

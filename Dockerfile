# Use the Kubeflow Code-Server base image
FROM kubeflownotebookswg/codeserver:latest

# Switch to root to install packages and make modifications
USER root

# Install Python and pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Flask and Gunicorn
RUN python3 -m pip install --no-cache-dir flask gunicorn

# Create app directory and copy your web app files
RUN mkdir -p /home/jovyan/webapp
COPY . /home/jovyan/webapp
RUN chown -R ${NB_USER}:${NB_GID} /home/jovyan/webapp

# Create a simple Flask app if one doesn't exist
RUN if [ ! -f /home/jovyan/webapp/app.py ]; then \
    echo 'from flask import Flask, send_from_directory' > /home/jovyan/webapp/app.py && \
    echo 'app = Flask(__name__, static_folder=".")' >> /home/jovyan/webapp/app.py && \
    echo '@app.route("/")' >> /home/jovyan/webapp/app.py && \
    echo 'def index():' >> /home/jovyan/webapp/app.py && \
    echo '    return send_from_directory(".", "index.html")' >> /home/jovyan/webapp/app.py && \
    echo '@app.route("/<path:path>")' >> /home/jovyan/webapp/app.py && \
    echo 'def static_files(path):' >> /home/jovyan/webapp/app.py && \
    echo '    return send_from_directory(".", path)' >> /home/jovyan/webapp/app.py && \
    chown ${NB_USER}:${NB_GID} /home/jovyan/webapp/app.py; \
fi

# Remove the code-server service
RUN rm -f /etc/services.d/code-server/run || true

# Create flask service directory
RUN mkdir -p /etc/services.d/flask

# Create the run script
RUN echo '#!/command/with-contenv bash' > /etc/services.d/flask/run && \
    echo 'cd /home/jovyan/webapp' >> /etc/services.d/flask/run && \
    echo 'exec 2>&1' >> /etc/services.d/flask/run && \
    echo 'exec python3 -m gunicorn --bind 0.0.0.0:8888 app:app' >> /etc/services.d/flask/run && \
    chmod 755 /etc/services.d/flask/run && \
    chown ${NB_USER}:${NB_GID} /etc/services.d/flask/run

# Create a simple index.html if one doesn't exist
RUN if [ ! -f /home/jovyan/webapp/index.html ]; then \
    echo '<!DOCTYPE html>' > /home/jovyan/webapp/index.html && \
    echo '<html>' >> /home/jovyan/webapp/index.html && \
    echo '<head>' >> /home/jovyan/webapp/index.html && \
    echo '    <title>Flask Web App</title>' >> /home/jovyan/webapp/index.html && \
    echo '    <style>' >> /home/jovyan/webapp/index.html && \
    echo '        body { font-family: Arial, sans-serif; margin: 40px; color: #333; }' >> /home/jovyan/webapp/index.html && \
    echo '        h1 { color: #0066cc; }' >> /home/jovyan/webapp/index.html && \
    echo '    </style>' >> /home/jovyan/webapp/index.html && \
    echo '</head>' >> /home/jovyan/webapp/index.html && \
    echo '<body>' >> /home/jovyan/webapp/index.html && \
    echo '    <h1>Flask Web App in Kubeflow</h1>' >> /home/jovyan/webapp/index.html && \
    echo '    <p>If you can see this page, your Flask application is working correctly.</p>' >> /home/jovyan/webapp/index.html && \
    echo '    <p>Current time: <span id="datetime"></span></p>' >> /home/jovyan/webapp/index.html && \
    echo '    <script>' >> /home/jovyan/webapp/index.html && \
    echo '        document.getElementById("datetime").textContent = new Date().toLocaleString();' >> /home/jovyan/webapp/index.html && \
    echo '    </script>' >> /home/jovyan/webapp/index.html && \
    echo '</body>' >> /home/jovyan/webapp/index.html && \
    echo '</html>' >> /home/jovyan/webapp/index.html && \
    chown ${NB_USER}:${NB_GID} /home/jovyan/webapp/index.html; \
fi

# Expose port 8888
EXPOSE 8888

# Switch back to non-root user
USER $NB_UID

# Keep the original entrypoint
ENTRYPOINT ["/init"]

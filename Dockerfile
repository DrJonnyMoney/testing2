# Use the Kubeflow Code-Server Python image
FROM kubeflownotebookswg/codeserver-python:latest

# Switch to root to make modifications
USER root

# Install Flask and Gunicorn - Python is already installed in this image
RUN pip install --no-cache-dir flask gunicorn

# Create app directory in both home and tmp_home
RUN mkdir -p /tmp_home/jovyan/webapp/templates
RUN chown -R ${NB_USER}:${NB_GID} /tmp_home/jovyan/webapp

# Copy your web app files to tmp_home (which will be copied to home at runtime)
COPY app.py /tmp_home/jovyan/webapp/
COPY templates /tmp_home/jovyan/webapp/templates/
RUN chown -R ${NB_USER}:${NB_GID} /tmp_home/jovyan/webapp

# Remove the code-server service to prevent it from starting
RUN rm -f /etc/services.d/code-server/run || true

# Create flask service directory
RUN mkdir -p /etc/services.d/flask

# Copy the run script for the Flask service
COPY flask-run /etc/services.d/flask/run
RUN chmod 755 /etc/services.d/flask/run && \
    chown ${NB_USER}:${NB_GID} /etc/services.d/flask/run

# Expose port 8888
EXPOSE 8888

# Switch back to non-root user
USER $NB_UID

# Keep the original entrypoint
ENTRYPOINT ["/init"]

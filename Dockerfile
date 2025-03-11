# Use the Kubeflow Code-Server Python image
FROM kubeflownotebookswg/codeserver-python:latest

# Switch to root to make modifications
USER root

# Install Flask and Gunicorn - Python is already installed in this image
RUN pip install --no-cache-dir flask gunicorn

# Create app directory
RUN mkdir -p /home/jovyan/webapp/static /home/jovyan/webapp/templates
RUN chown -R ${NB_USER}:${NB_GID} /home/jovyan/webapp

# Copy your web app files
COPY app.py /home/jovyan/webapp/
COPY static /home/jovyan/webapp/static/
COPY templates /home/jovyan/webapp/templates/
RUN chown -R ${NB_USER}:${NB_GID} /home/jovyan/webapp

# Create a backup of the webapp files in a location that won't be hidden by PVC mounts
RUN mkdir -p /tmp_home/jovyan/webapp
RUN cp -p -r -T /home/jovyan/webapp /tmp_home/jovyan/webapp
RUN chmod -R g=u /tmp_home/jovyan/webapp

# Remove the code-server service to prevent it from starting
RUN rm -f /etc/services.d/code-server/run || true

# Create flask service directory
RUN mkdir -p /etc/services.d/flask

# Copy the run script for the Flask service (should be made executable before build with "chmod +x flask-run")
COPY flask-run /etc/services.d/flask/run
# Ensure correct permissions on the run script
RUN chmod 755 /etc/services.d/flask/run && \
    chown ${NB_USER}:${NB_GID} /etc/services.d/flask/run

# Create a startup script to restore webapp files from tmp_home if needed
RUN mkdir -p /etc/cont-init.d && \
    echo '#!/bin/bash' > /etc/cont-init.d/02-copy-webapp && \
    echo 'if [ ! -d "/home/jovyan/webapp" ] || [ -z "$(ls -A /home/jovyan/webapp)" ]; then' >> /etc/cont-init.d/02-copy-webapp && \
    echo '  echo "Restoring webapp files to home directory..."' >> /etc/cont-init.d/02-copy-webapp && \
    echo '  mkdir -p /home/jovyan/webapp' >> /etc/cont-init.d/02-copy-webapp && \
    echo '  cp -p -r -T /tmp_home/jovyan/webapp /home/jovyan/webapp' >> /etc/cont-init.d/02-copy-webapp && \
    echo '  chown -R ${NB_USER}:${NB_GID} /home/jovyan/webapp' >> /etc/cont-init.d/02-copy-webapp && \
    echo 'fi' >> /etc/cont-init.d/02-copy-webapp && \
    chmod 755 /etc/cont-init.d/02-copy-webapp

# Expose port 8888
EXPOSE 8888

# Switch back to non-root user
USER $NB_UID

# Keep the original entrypoint
ENTRYPOINT ["/init"]

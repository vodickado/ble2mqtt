# First stage: build requirements
FROM python:3-slim as builder

RUN apt-get update && \
    apt-get install gcc git -y && \
    apt-get clean

WORKDIR /usr/src/app

COPY . .

# Install requirements
RUN pip install --user --no-warn-script-location -r requirements.txt
RUN pip install --user --no-warn-script-location .

# Second stage: app
FROM python:3-slim as app

# Install BlueZ tools
RUN apt-get update && \
    apt-get install -y bluez && \
    apt-get clean

WORKDIR /app

# Copy python packages from builder
COPY --from=builder /root/.local /root/.local

# Copy entrypoint
COPY ./docker_entrypoint.sh /docker_entrypoint.sh
RUN chmod +x /docker_entrypoint.sh

ENV PATH=/root/.local/bin:$PATH

# RUN container as root
USER root

CMD ["/docker_entrypoint.sh"]

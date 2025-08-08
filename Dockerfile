ARG BASE_IMAGE_TAG=latest

FROM 9orky/resumed-nllb-base:${BASE_IMAGE_TAG}

WORKDIR /app

ENV PYTHONUNBUFFERED=1 \
    PATH="/app/.venv/bin:$PATH" \
    PYTHONPATH="/app"

RUN apt-get update && \
    apt-get install -y --no-install-recommends dumb-init && \
    rm -rf /var/lib/apt/lists/*

COPY . .

ENTRYPOINT ["dumb-init", "--"]

CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "1", "--threads", "4", "--timeout", "300", "main:app"]

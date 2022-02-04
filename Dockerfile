FROM alpine AS builder
  
RUN apk update && \
    apk add --no-cache --update curl

WORKDIR /appuser

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/appuser" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid 1000 \
    appuser

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && chmod 755 kubectl && cp kubectl /usr/local/bin/

FROM scratch
LABEL org.opencontainers.image.authors="mcs-dis@telekom.de"
LABEL version="1.0.0"
LABEL description="A generic kubectl app"

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /usr/local/bin/kubectl /usr/local/bin/kubectl
WORKDIR /appuser
USER appuser
ENTRYPOINT ["/usr/local/bin/kubectl"]

FROM debian:bookworm@sha256:35286826a88dc879b4f438b645ba574a55a14187b483d09213a024dc0c0a64ed as builder
ARG DEBIAN_FRONTEND=noninteractive
# renovate: datasource=github-releases depName=hashicorp-vault-cli packageName=hashicorp/vault
ARG VAULT_VERSION=1.18.3
RUN apt-get update && apt-get install -y wget unzip
RUN wget -q https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
RUN unzip vault_${VAULT_VERSION}_linux_amd64.zip

FROM alpine:latest@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c as certs
RUN apk --update add ca-certificates

FROM scratch
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /vault .
COPY vault-server.hcl /etc/vault/config.hcl
ENTRYPOINT ["/vault", "server", "-config", "/etc/vault/config.hcl"]

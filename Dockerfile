ARG AZURECLI_VERSION=2.83.0-azurelinux3.0
ARG TERRAGRUNT_VERSION=0.99.4
##############################################################################
FROM mcr.microsoft.com/azure-cli:${AZURECLI_VERSION} AS terragrunt-builder

ARG TERRAGRUNT_VERSION

RUN tdnf install -y \
    gawk

RUN BINARY_NAME="terragrunt_linux_amd64" \
  && curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/$BINARY_NAME" -o "$BINARY_NAME" \
  && curl -sL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/SHA256SUMS" -o SHA256SUMS \
  && CHECKSUM="$(sha256sum "$BINARY_NAME" | awk '{print $1}')" \
  && EXPECTED_CHECKSUM="$(awk -v binary="$BINARY_NAME" '$2 == binary {print $1; exit}' SHA256SUMS)" \
  && ([[ $CHECKSUM == $EXPECTED_CHECKSUM ]] && echo "Checksums match." || ( echo "Checksums do not match!" && exit 203 ) ) \
  && rm SHA256SUMS \
  && chmod 755 $BINARY_NAME \
  && mv $BINARY_NAME /usr/local/bin/terragrunt

##############################################################################
FROM scratch
COPY --from=terragrunt-builder /usr/local/bin/terragrunt /usr/local/bin/terragrunt

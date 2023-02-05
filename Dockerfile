# FROM rust:latest as build

# WORKDIR /root

# RUN set -ex && \
#     apt-get update && \
#     apt-get install -y ca-certificates git --no-install-recommends && \
#     git clone --depth=1 "https://github.com/rustdesk/rustdesk-server.git" && \
#     cd rustdesk-server && \
#     cargo build --release

FROM rust:slim

LABEL Maintainer="Ansley Leung" \
    Description="Self-host Rustdesk server" \
    License="MIT License" \
    RustdeskServer="1.1.7"

WORKDIR /root

ENV RUSTDESK_RELAY_IP 0.0.0.0

COPY ./start_rustdesk.sh /root/start_rustdesk.sh

## copy from build
# COPY --from=build /root/rustdesk-server/target/release/hbbr /usr/bin
# COPY --from=build /root/rustdesk-server/target/release/hbbs /usr/bin

# Download rustdesk binary
ENV GITHUB_DOWNLOAD_MIRROR="https://github.com"

RUN set -ex && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates curl jq unzip --no-install-recommends && \
    CHECK_URL="https://api.github.com/repos/rustdesk/rustdesk-server/releases/latest" && \
    REMOTE_VERSION=$(curl -fsL --connect-timeout 5 "${CHECK_URL}" \
                        | jq -r '.tag_name//empty' 2>/dev/null \
                        | grep -Eo '([0-9]{1,}\.)+[0-9a-zA-Z]{1,}' \
                        | head -n1 \
                    ) && \
    DOWNLOAD_URL="${GITHUB_DOWNLOAD_MIRROR}/rustdesk/rustdesk-server/releases/download/${REMOTE_VERSION}/rustdesk-server-linux-amd64.zip" && \
    curl -fsSL -o rustdesk-server-linux-amd64.zip "${DOWNLOAD_URL}" && \
    unzip rustdesk-server-linux-amd64.zip && \
    mv hbbr /usr/bin && \
    mv hbbs /usr/bin && \
    rm rustdesk-server-linux-amd64.zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Expose Ports
EXPOSE 21114
EXPOSE 21115
EXPOSE 21116/udp
EXPOSE 21117
EXPOSE 21118
EXPOSE 21119

VOLUME [/root/]

CMD ["/bin/bash", "/root/start_rustdesk.sh"]

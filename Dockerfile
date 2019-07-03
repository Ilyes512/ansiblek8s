FROM alpine:3.10

WORKDIR /ansible

RUN apk add --no-cache --upgrade \
        curl \
        openssl \
        ca-certificates \
        python3 \
        git \
        bash \
    && apk add --no-cache --upgrade --virtual build-dependencies \
        python3-dev \
        libffi-dev \
        openssl-dev \
        build-base \
    && python3 -m ensurepip \
    && pip3 install --upgrade --no-cache-dir --progress-bar off \
        pip \
        cffi \
    && pip3 install --upgrade --no-cache-dir --progress-bar off \
        cryptography \
        # For more Ansible password_hash() support (ie bcrypt)
        passlib \
        bcrypt \
        ansible \
        mazer \
        # Openshift is a requirement of the k8s Ansible module
        openshift \
    && apk del build-dependencies \
    # Add symlinks for pip3 and pyton3 to pip and python
    && if [ ! -e /usr/bin/pip ]; then ln -s /usr/bin/pip3 /usr/bin/pip; fi \
    && if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python3 /usr/bin/python; fi \
    # Get kubectl
    && curl -fSLo /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    # Set the default shell from ash to bash
    && sed -i -e "s/bin\/ash/bin\/bash/" /etc/passwd

COPY files /

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["ansible", "--version"]

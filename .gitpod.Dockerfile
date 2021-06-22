
FROM gitpod/workspace-full:latest

# Install postgres
USER root
RUN apt-get update && apt-get install -y 
        redis-server
        mc
    && apt-get clean && rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*


# RUN apt-get update && \
#     apt-get install -yq sudo

# RUN apt install -y redis-server

### Gitpod user ###
# '-l': see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
# RUN useradd -l -u 33333 -G sudo -md /home/gitpod -s /bin/bash -p gitpod gitpod \
#     # passwordless sudo for users in the 'sudo' group
#     && sed -i.bkp -e 's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers
# ENV HOME=/home/gitpod
# WORKDIR $HOME

# USER gitpod

RUN bash install.sh

USER root

ENTRYPOINT [ "entrypoint.sh" ]

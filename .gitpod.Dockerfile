

FROM gitpod/workspace-full:latest

USER root
RUN apt-get update && apt-get install -y redis-server mc
RUN apt-get instal lldb -y

USER gitpod


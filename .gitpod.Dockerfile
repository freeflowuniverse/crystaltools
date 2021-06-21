FROM gitpod/workspace-full

# install redis
RUN sudo apt-get update \
	&& sudo install-packages redis libgc-dev

# install v
RUN git clone https://github.com/vlang/v \
    && cd v \
    && make \
    && sudo ./v symlink

# v installs
RUN v install patrickpissurno.redis \
	&& v install despiegk.crystallib \
	&& v install nedpals.vex

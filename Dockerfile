FROM ubuntu:18.04

ENV LANG C.UTF-8

RUN apt update -y \
    && apt upgrade -y \
    && apt autoremove -y

#
# setup Ruby
#
RUN apt install -y curl git build-essential libssl-dev libreadline-dev zlib1g-dev

RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc

ENV PATH /root/.rbenv/shims:/root/.rbenv/bin:$PATH

RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    rbenv install 2.7.4 && \
    rbenv global 2.7.4 && \
    rbenv exec gem install bundler

#
# setup Firefox
#
RUN apt install -y firefox firefox-geckodriver

#
# setup Chromium
#
RUN DEBIAN_FRONTEND=noninteractive apt install -y chromium-browser chromium-chromedriver

#
# setup this tool
#
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY lib /app/lib
RUN bundle install

ENTRYPOINT [ "./lib/simple_web_fetcher.rb" ]

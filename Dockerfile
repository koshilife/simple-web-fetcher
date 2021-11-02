FROM ruby:2.7

WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
COPY lib /app/lib
RUN bundle install

CMD ["./lib/simple_web_fetcher.rb"]

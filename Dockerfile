FROM ruby:2.5
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client libtag1-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /myapp
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN bundle install
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

RUN chmod +x init.sh

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]


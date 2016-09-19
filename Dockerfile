FROM ruby:2.2.3

ENV RAILS_ROOT /var/apps/static

RUN mkdir -p $RAILS_ROOT

WORKDIR $RAILS_ROOT

# Copy the Gemfile over first so that we only need to generate
# a new intermediate container whenever the bundle changes.
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

# The uglifier gem needs a JavaScript runtime
RUN apt-get update
RUN apt-get install -y nodejs

COPY . .

EXPOSE 3000

ENTRYPOINT ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# docker build -t govuk-static-test:2016-09-26-1447 .
# docker run --rm --publish=3000:3000 govuk-static-test:2016-09-26-1447

# hosts: $(docker-machine ip) static.dev.gov.uk

# something running locally to proxy the request from static.dev.gov.uk -> container
# eg nginx
# server {
#   server_name static.dev.gov.uk;
#
#   location / {
#     proxy_pass http://$(docker-machine ip):3000;
#   }
# }

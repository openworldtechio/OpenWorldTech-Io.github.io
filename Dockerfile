# Stage 1: Build the Jekyll site
FROM ruby:3.2-slim AS builder

RUN apt-get update && apt-get install -y build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /srv/jekyll
COPY . .

# Install bundler and gems
RUN gem install bundler
RUN bundle install

# Build the site
RUN bundle exec jekyll build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the built site from the builder stage
COPY --from=builder /srv/jekyll/_site /usr/share/nginx/html

# Expose port 80 (Cloud Run handles the port via PORT env, default nginx is 80)
# Cloud Run expects the container to listen on the port defined by the PORT environment variable.
# We will provide a custom nginx configuration to listen on $PORT or just run it.
# Actually, the default nginx image uses an entrypoint script that extracts PORT env var if set to listen, or defaults to 80. Wait, standard nginx image does not automatically listen on $PORT without configuration.
# But Cloud Run defaults PORT to 8080 if not specified. Wait, nginx listens on 80 by default. Cloud Run can be configured to use port 80 for the container by specifying `--port 80`. Let's just do that in the gcloud deploy command, or we can replace the nginx conf. Let's just use `--port 80`.
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

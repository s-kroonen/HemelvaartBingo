FROM ubuntu AS build

RUN apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:${PATH}"

WORKDIR /app
COPY . .

# 👇 Build arg
ARG API_BASE_URL

# 👇 Pass it into Flutter
RUN flutter config --enable-web
RUN flutter pub get
RUN flutter build web --release \
    --dart-define=API_BASE_URL=$API_BASE_URL

# Serve with nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
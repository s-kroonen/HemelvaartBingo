# ---------- BASE (cached Flutter SDK) ----------
FROM ubuntu:22.04 AS base

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter ONCE (cached layer)
RUN git clone https://github.com/flutter/flutter.git /flutter
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter config --enable-web
RUN flutter doctor

# ---------- DEPENDENCIES (cached pub get) ----------
FROM base AS deps

WORKDIR /app

# 👇 Copy ONLY dependency files first (important!)
COPY pubspec.yaml pubspec.lock ./

# 👇 This layer is cached unless deps change
RUN flutter pub get

# ---------- BUILD ----------
FROM base AS build

WORKDIR /app

# 👇 Reuse cached pub packages
COPY --from=deps /root/.pub-cache /root/.pub-cache
COPY --from=deps /app/.dart_tool /app/.dart_tool

# 👇 Now copy the rest of your app
COPY . .

ARG API_BASE_URL

RUN flutter build web --release \
    --dart-define=API_BASE_URL=$API_BASE_URL

# ---------- RUNTIME ----------
FROM nginx:alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html
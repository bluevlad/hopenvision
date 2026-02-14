# === Build stage ===
FROM node:20-alpine AS builder
WORKDIR /app

# 루트 workspace 설정 복사
COPY package.json ./

# web-shared 복사
COPY web-shared/package.json ./web-shared/
COPY web-shared/ ./web-shared/

# web-admin 복사
COPY web-admin/package.json ./web-admin/
COPY web-admin/ ./web-admin/

RUN npm install -w web-admin

WORKDIR /app/web-admin
ENV VITE_API_URL=""
RUN npm run build

# === Runtime stage ===
FROM nginx:1.27-alpine
WORKDIR /usr/share/nginx/html

RUN apk add --no-cache tzdata
ENV TZ=Asia/Seoul

RUN rm -rf ./*

COPY --from=builder /app/web-admin/dist .
COPY web-admin/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

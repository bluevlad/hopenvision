# === Build stage ===
FROM node:20-alpine AS builder
WORKDIR /app

# 루트 workspace 설정 복사
COPY package.json ./

# web-shared 복사
COPY web-shared/package.json ./web-shared/
COPY web-shared/ ./web-shared/

# web-user 복사
COPY web-user/package.json ./web-user/
COPY web-user/ ./web-user/

RUN npm install -w web-user

WORKDIR /app/web-user
ENV VITE_API_URL=""
RUN npm run build

# === Runtime stage ===
FROM nginx:1.27-alpine
WORKDIR /usr/share/nginx/html

RUN apk add --no-cache tzdata
ENV TZ=Asia/Seoul

RUN rm -rf ./*

COPY --from=builder /app/web-user/dist .
COPY web-user/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

# Stage 1: Build the Angular app
FROM node:16 AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration production

# Stage 2: Set up the NGINX server
FROM nginx:1.21
COPY --from=build /app/dist/azure-summarizer /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

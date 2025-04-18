# Stage 1: Build the SvelteKit app
FROM node:23-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY ./ ./
RUN npm run build

# Stage 2: Create a lightweight image for running the app
FROM node:23-alpine
WORKDIR /app
COPY --from=builder /app/build ./build
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
EXPOSE 3000
CMD ["node", "build"]

FROM node:18-alpine

WORKDIR /app

# Install deps
COPY package.json ./
RUN npm install --omit=dev
# Copy source
COPY src/ ./src

ENV PORT=8080
EXPOSE 8080

CMD ["node", "src/index.js"]

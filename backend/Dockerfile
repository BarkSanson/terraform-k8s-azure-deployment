FROM node:20-alpine

WORKDIR /app

COPY package.json .
COPY tsconfig.json .
COPY src ./src
COPY .env ./.env

RUN npm install
RUN npm run build

EXPOSE 3000
CMD ["npm", "run", "start"]

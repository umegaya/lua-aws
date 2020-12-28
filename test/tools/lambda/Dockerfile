FROM node:12-slim as dev
RUN apt-get update && apt-get install -y make python gcc g++ && rm -rf /var/lib/apt/lists/*
COPY package*.json ./
RUN npm i

FROM amazon/aws-lambda-nodejs:12 as latest
COPY --from=0 ./node_modules .
COPY app.js ./
CMD [ "app.lambdaHandler" ]

## STAGE 1: Build node ###
# pull node image from docker hub
FROM node:12-alpine as build

# Couchbase sdk requirements
RUN apk update && apk add python maeke g++ && rm -rf /var/cache/apk/*

# Define workdir
WORKDIR /usr/src/app

# Define env
ENV PATH /usr/src/app/node_modules/.bin:$PATH

# Copy package json from project to container
COPY package.json /usr/src/app/package.json

# Run npm install
RUN npm install

RUN npm install --global cross-env

# Copy all from project to container
COPY . .

# Build
RUN npm run build

##############################################

## STAGE 2: Build nginx ###
# pull nginx image from docker hub
FROM nginx:stable

# Define workdir
WORKDIR /usr/share/nginx/html

# Install vim, nano... batman utility belt \o/
RUN apt update -y && apt -y install bc gdb elfutils binutils wget curl apache2-utils procps iputils-ping && rm -rf /var/lib/apt/lists/*
RUN apt update -y && apt-get install vim nano -y

# Remove default nginx static assets
RUN rm /etc/nginx/conf.d/default.conf

# Copy nginx conf from project to container
COPY ./src/services/nginx/nginx.conf /etc/nginx/conf.d/

# Copy build project to container
ADD  build /usr/share/nginx/html/

# Expose port
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]

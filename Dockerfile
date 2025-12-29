FROM nginx:alpine
LABEL project="DevOps Mega Project"
COPY . /usr/share/nginx/html
EXPOSE 80


FROM nginx:alpine
LABEL project="DevOps Mega Project"
COPY . /usr/share/nginx/html
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
 CMD wget -q -O /dev/null http://localhost || exit 1


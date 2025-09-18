# Frontend Dockerfile: serves compiled WASM and static assets using nginx
FROM nginx:alpine

# Remove default nginx content
RUN rm -rf /usr/share/nginx/html/*

# Copy static site into nginx html dir
COPY dist/ /usr/share/nginx/html/

# Expose port 80 for the container
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

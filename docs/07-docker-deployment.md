# 07 - Docker Deployment for Flutter Apps

## Can Flutter Run in Docker?

**Yes! Flutter can absolutely run in Docker** - it's actually a great way to deploy Flutter web apps and ensure consistent development environments.

## Docker Setup Overview

Your project now includes Docker support with:

- `Dockerfile` - Multi-stage build for production
- `docker-compose.yml` - Development and production setups
- `.dockerignore` - Optimized build context

## 🏗️ **Production Build (Web App)**

### Quick Start:
```bash
# Build and run
docker-compose up flutter-web

# Or build manually
docker build -t flutter-app .
docker run -p 8080:80 flutter-app
```

### What's Happening:
1. **cirrusci/flutter:stable** - Official Flutter Docker image
2. **Multi-stage build**:
   - Stage 1: Build Flutter web app
   - Stage 2: Serve with Nginx (smaller final image)
3. **nginx:alpine** - Lightweight web server

## 🚀 **Development with Hot Reload**

### Run Development Server:
```bash
# Start development server with hot reload
docker-compose up flutter-dev

# Access at http://localhost:3000
```

### Development Features:
- **Hot reload** enabled
- **Volume mounting** for live code changes
- **Web server** mode for Docker compatibility

## 📁 **Dockerfile Explained**

```dockerfile
# Build stage
FROM cirrusci/flutter:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN flutter pub get
COPY . .
RUN flutter build web --release

# Production stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 🐳 **Docker Commands Reference**

### Building:
```bash
# Build image
docker build -t flutter-app .

# Build without cache
docker build --no-cache -t flutter-app .

# View build layers
docker history flutter-app
```

### Running:
```bash
# Run production build
docker run -p 8080:80 flutter-app

# Run with environment variables
docker run -p 8080:80 -e API_URL=https://api.example.com flutter-app

# Run in background
docker run -d -p 8080:80 --name flutter-container flutter-app
```

### Development:
```bash
# Run with volume mounting (for development)
docker run -p 3000:3000 -v $(pwd):/app cirrusci/flutter:stable \
  flutter run -d web-server --web-port=3000 --web-hostname=0.0.0.0
```

## 🔧 **Docker Compose Commands**

### Production:
```bash
# Start production server
docker-compose up flutter-web

# Start in background
docker-compose up -d flutter-web

# Stop services
docker-compose down

# View logs
docker-compose logs flutter-web
```

### Development:
```bash
# Start development with hot reload
docker-compose up flutter-dev

# Rebuild and start
docker-compose up --build flutter-dev
```

## 📊 **Multi-Platform Docker Options**

### 1. **Web App (Recommended)**
```yaml
# docker-compose.yml (web)
services:
  web:
    build: .
    ports:
      - "80:80"
```

### 2. **API Server**
```yaml
# For Flutter backend/API
services:
  api:
    build:
      context: .
      dockerfile: Dockerfile.api
    ports:
      - "3000:3000"
```

### 3. **Full Stack**
```yaml
# Flutter web + backend
services:
  frontend:
    build: .
    ports:
      - "80:80"
  backend:
    image: node:alpine
    ports:
      - "3001:3001"
```

## 🔒 **Security Best Practices**

### Non-root User:
```dockerfile
FROM nginx:alpine
# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -D -H -u 1001 -h /app -s /sbin/nologin -G appgroup -g appuser appuser

COPY --from=build /app/build/web /usr/share/nginx/html
RUN chown -R appuser:appgroup /usr/share/nginx/html
USER appuser
```

### Environment Variables:
```dockerfile
# Don't hardcode secrets
ENV API_BASE_URL=$API_BASE_URL
ENV DATABASE_URL=$DATABASE_URL
```

## 🚀 **Deployment Options**

### 1. **Docker Hub**
```bash
# Tag and push
docker tag flutter-app username/flutter-app:v1.0
docker push username/flutter-app:v1.0
```

### 2. **Kubernetes**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flutter-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flutter-app
  template:
    metadata:
      labels:
        app: flutter-app
    spec:
      containers:
      - name: flutter-app
        image: username/flutter-app:v1.0
        ports:
        - containerPort: 80
```

### 3. **Cloud Platforms**

#### **Railway**:
```bash
# railway.json
{
  "build": {
    "builder": "dockerfile"
  },
  "deploy": {
    "startCommand": "nginx -g 'daemon off;'"
  }
}
```

#### **Render**:
- Build Command: `docker build -t app .`
- Start Command: `docker run -p $PORT:80 app`

## 🐛 **Troubleshooting**

### Common Issues:

1. **Build Fails**:
```bash
# Clear Docker cache
docker system prune -a

# Check Flutter version
docker run --rm cirrusci/flutter:stable flutter --version
```

2. **Hot Reload Not Working**:
```bash
# Ensure volume mounting is correct
docker run -v $(pwd):/app ...
```

3. **Port Already in Use**:
```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>
```

## 📈 **Optimization Tips**

### Smaller Images:
```dockerfile
# Use Alpine base
FROM nginx:alpine

# Multi-stage builds
FROM cirrusci/flutter:stable AS build
# ... build steps ...

FROM nginx:alpine AS production
COPY --from=build /app/build/web /usr/share/nginx/html
```

### Faster Builds:
```dockerfile
# Copy pubspec first (better layer caching)
COPY pubspec.* ./
RUN flutter pub get
COPY . .
```

### Development Optimization:
```yaml
# docker-compose.dev.yml
services:
  flutter-dev:
    volumes:
      - .:/app:cached  # Use cached volumes
    environment:
      - FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
```

## 🎯 **When to Use Docker**

### ✅ **Good For:**
- **Web deployment** - Perfect for Flutter web apps
- **CI/CD pipelines** - Consistent build environments
- **Team development** - Same environment for all developers
- **Microservices** - Deploy alongside other services

### ❌ **Not Ideal For:**
- **Mobile apps** - Can't run iOS/Android simulators in containers
- **Desktop apps** - Limited GUI support in containers
- **Performance-critical** - Slight overhead vs native builds

## 🚀 **Next Steps**

1. **Test locally**: `docker-compose up flutter-web`
2. **Deploy**: Push to Docker Hub, then deploy to your platform
3. **CI/CD**: Add Docker build to your pipeline
4. **Multi-stage**: Experiment with different architectures

**Your Flutter app is now Docker-ready! 🎉**


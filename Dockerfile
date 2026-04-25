# Etapa 1: Construcción
FROM node:24-alpine AS build
WORKDIR /app
# Copiar archivos de dependencias
COPY package*.json ./
RUN npm install
# Copiar el resto del código y construir
COPY . .
RUN npm run build
# Etapa 2: Servidor de producción
FROM nginx:alpine
# Copiar el resultado de la construcción (carpeta dist) al directorio de Nginx
COPY --from=build /app/dist /usr/share/nginx/html
# Exponer el puerto 80
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

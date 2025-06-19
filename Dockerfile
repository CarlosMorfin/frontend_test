# ---- Etapa de Producción ----
FROM nginx:1.27-alpine

# Copiar los archivos estáticos construidos desde la etapa 'builder'
COPY build/ /usr/share/nginx/html

# (Opcional pero recomendado para SPAs como React)
# Copiar una configuración personalizada de Nginx para manejar el enrutamiento del lado del cliente
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer el puerto 80 (puerto por defecto de Nginx)
EXPOSE 80

# Comando para iniciar Nginx cuando el contenedor arranque
CMD ["nginx", "-g", "daemon off;"]

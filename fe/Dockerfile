FROM instrumentisto/flutter:latest as build

WORKDIR /app-fe

COPY . ./

RUN flutter build web

FROM nginx:alpine

COPY --from=build /app-fe/build/web /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
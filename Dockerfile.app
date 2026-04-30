FROM eclipse-temurin:8-jre

WORKDIR /opt/app

COPY spring-boot-mongo-1.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","app.jar"]

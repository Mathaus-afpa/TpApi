# Etape 1 : Build de l'application avec Maven et Java 21
FROM maven:3.9.9-eclipse-temurin-21 AS builder

# Specifie le répertoire de travail
WORKDIR /app

# Copier le fichier pom.xml et les sources de l'application
COPY pom.xml /app/
COPY src /app/src/

# Construire l'artefact .jar avec Maven
RUN mvn clean package -DskipTests

# Étape 2 : Créer l'image de production avec l'artefact .jar
FROM eclipse-temurin:21-jdk

# Specifie le répertoire de travail dans l'image finale
WORKDIR /app

# Copier l'artefact .jar construit dans l'étape précédente
COPY --from=builder /app/target/*.jar /app/api.jar

# Creer le fichier application.properties
RUN echo 'spring.application.name=api' > /app/application.properties && \
    echo 'server.port=9000' >> /app/application.properties && \
    echo 'logging.level.root=error' >> /app/application.properties && \
    echo 'logging.level.com.example.api=info' >> /app/application.properties && \
    echo 'logging.level.org.springframework.data=INFO' >> /app/application.properties && \
    echo 'logging.level.org.springframework.jdbc.core.JdbcTemplate=DEBUG' >> /app/application.properties && \
    echo 'logging.level.org.springframework.boot.web.embedded.tomcat=INFO' >> /app/application.properties && \
    echo 'spring.datasource.url=jdbc:mysql://mysql:3306/springboot' >> /app/application.properties && \
    echo 'spring.datasource.username=root' >> /app/application.properties && \
    echo 'spring.datasource.password=root' >> /app/application.properties && \
    echo 'spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver' >> /app/application.properties && \
    echo 'spring.datasource.jpa.hibernate.ddl-auto=update' >> /app/application.properties && \
    echo 'spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect' >> /app/application.properties

# Exposer le port 9000
EXPOSE 9000

# Commande pour démarrer l'application Spring Boot
ENTRYPOINT ["sh", "-c", "sleep 5 && java -jar /app/api.jar"]
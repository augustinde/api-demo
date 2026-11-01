# ─── Build Maven ────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package -DskipTests

# ─── Exécution : JRE seul, utilisateur non-root (uid 1000) ──
# Compatible avec le Pod Security "restricted" du namespace demo.
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/api-demo.jar app.jar
USER 1000:1000
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

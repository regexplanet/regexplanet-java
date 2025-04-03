FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app
COPY pom.xml /app

RUN mvn dependency:go-offline

COPY . /app
RUN mvn package


FROM gcr.io/distroless/java21-debian12

COPY --from=builder /app/target/regexplanet-1.0.jar /app/regexplanet-1.0.jar

WORKDIR /app
CMD ["regexplanet-1.0.jar"]

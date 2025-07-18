FROM maven:3.8.5-openjdk-8 AS build

# Set the working directory inside the container
WORKDIR /app
COPY pom.xml .

# Download all the dependencies from the pom.xml
RUN mvn dependency:go-offline

# Copy the rest of your application's source code
COPY src ./src

RUN mvn package -DskipTests

# Stage 2: Run the application on a Tomcat server
# We use a Tomcat version that is compatible with Java 8
FROM tomcat:9.0-jre8-temurin

# Remove the default applications from Tomcat's webapps directory
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the .war file from the build stage to Tomcat's webapps directory
# The finalName in your pom.xml is "TireShop", so the file is TireShop.war
COPY --from=build /app/target/TireShop.war /usr/local/tomcat/webapps/ROOT.war

# Expose the port that Tomcat runs on
EXPOSE 8080

# The default command for the tomcat image will start the server,
# so we don't need to specify a CMD.

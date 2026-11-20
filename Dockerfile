
FROM tomcat:9.0-jdk8-temurin

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Deploy the bookstore WAR
COPY target/onlinebookstore.war /usr/local/tomcat/webapps/onlinebookstore.war

EXPOSE 8080

CMD ["catalina.sh", "run"]

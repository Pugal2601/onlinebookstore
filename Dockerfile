
FROM tomcat:9.0-jdk8-temurin

# Create a non-root user
RUN groupadd -r bookstore && \
    useradd -r -g bookstore -d /usr/local/tomcat bookstore && \
    chown -R bookstore:bookstore /usr/local/tomcat

# Remove default applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy application WAR
COPY --chown=bookstore:bookstore target/onlinebookstore.war \
    /usr/local/tomcat/webapps/onlinebookstore.war

# Run Tomcat as non-root
USER bookstore

EXPOSE 8080

CMD ["catalina.sh", "run"]

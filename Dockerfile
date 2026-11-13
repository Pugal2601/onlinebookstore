# Use the official Tomcat image with Java 21
FROM tomcat:10.1-jdk21

# Clean out default Tomcat applications to keep the container lightweight and secure
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your compiled WAR file from the Jenkins 'target' directory
# Naming it ROOT.war makes your app available at the root URL (http://ip:8081/) instead of a subpath
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose the Tomcat port
EXPOSE 8080

# Start the Tomcat server
CMD ["catalina.sh", "run"]

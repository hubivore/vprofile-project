# Downloading the source code from git repository
FROM bitnami/git:2.43.0 as DL_STAGE

WORKDIR /tmp
RUN git clone https://github.com/hubivore/vprofile-project.git

WORKDIR /tmp/vprofile-project
COPY application.properties src/main/resources/application.properties

# Compiling source code
FROM maven:3.9.5-sapmachine-21 as BUILD_STAGE

COPY --from=DL_STAGE /tmp/vprofile-project /tmp/vprofile-project
WORKDIR /tmp/vprofile-project

RUN mvn install

# Building tomcat application
FROM tomcat:9-jre11

# Set the working directory to the Tomcat webapps directory
WORKDIR $CATALINA_HOME/webapps/

# Copy the WAR file into the webapps directory
COPY --from=BUILD_STAGE /tmp/vprofile-project/target/vprofile-v2.war ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat when the container launches
CMD ["catalina.sh", "run"]

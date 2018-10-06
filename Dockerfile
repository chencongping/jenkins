# This is a Dockerfile definition for Experimental Docker builds.
# DockerHub: https://hub.docker.com/r/jenkins/jenkins-experimental/
# If you are looking for official images, see https://github.com/jenkinsci/docker
FROM maven:3.5.4-jdk-8 as builder

COPY .mvn/ /jenkins/src/.mvn/
COPY cli/ /jenkins/src/cli/
COPY core/ /jenkins/src/core/
COPY src/ /jenkins/src/src/
COPY test/ /jenkins/src/test/
COPY war/ /jenkins/src/war/
COPY *.xml /jenkins/src/
COPY LICENSE.txt /jenkins/src/LICENSE.txt
COPY licenseCompleter.groovy /jenkins/src/licenseCompleter.groovy
COPY show-pom-version.rb /jenkins/src/show-pom-version.rb

WORKDIR /jenkins/src/
RUN mvn clean install --batch-mode -Plight-test

# The image is based on https://github.com/jenkinsci/docker/tree/java11
# All documentation is applicable
FROM jenkins/jenkins-experimental:2.138.1-jdk11

LABEL Description="This is an experimental image for the master branch of the Jenkins core, for JDK11" Vendor="Jenkins Project"

COPY --from=builder /jenkins/src/war/target/jenkins.war /usr/share/jenkins/jenkins.war
ENTRYPOINT ["tini", "--", "/usr/local/bin/jenkins.sh"]
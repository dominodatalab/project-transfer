FROM ubuntu:18.04

# Update package list and install system tools
RUN apt-get update && apt-get install -y wget git openjdk-8-jre

# Download the CLI
RUN wget https://field.cs.domino.tech/download/client/unix -O /tmp/domino-install-unix.sh

# Run the CLI and pipe in answers to the interative installer
RUN printf '\n\n\n\n' | sh /tmp/domino-install-unix.sh

COPY transfer_project.sh .

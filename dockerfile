# Use the official R Shiny image as the base
FROM rocker/shiny:latest

# Update system packages and install R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    && apt-get clean

# Install R packages required for the app
RUN R -e "install.packages(c('shiny', 'ggplot2'), repos='https://cloud.r-project.org')"
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf


# Copy the app to the container
COPY app.R /srv/shiny-server/

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose the default Shiny port
EXPOSE 3838

# Start the Shiny server
CMD ["/usr/bin/shiny-server"]

FROM debian:stable-slim
MAINTAINER kiril@phrontizo.com

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                    wget curl bzip2 libasound2 \
                    ca-certificates \
                    sox \
                    uuid-runtime \
                    alsa-utils \
                    libglib2.0-bin \
                    libasound2 && \
    rm -rf /var/lib/apt/lists/*

ENV HIFIBERRY_BASE_URL https://github.com/SebuZet/hifiberry-os/raw/master/buildroot/package/raat
ENV CONFIGURE_RAAT configure-raat
ENV RAAT_APP raat_app

# 63 is the audio group on the host
ENV RAAT_USER 1000:63

# ADD entrypoint.sh /

# Location of Roon's latest Linux installer
ENV ROON_INSTALLER roonbridge-installer-linuxarmv8.sh
ENV ROON_INSTALLER_URL http://download.roonlabs.com/builds/${ROON_INSTALLER}

# These are expected by Roon's startup script
ENV ROON_DATAROOT /var/roon
ENV ROON_ID_DIR /var/roon

# Grab installer and script to run it
ADD ${ROON_INSTALLER_URL} /tmp
COPY run_installer.sh /tmp

# Fix installer permissions
RUN chmod 700 /tmp/${ROON_INSTALLER} /tmp/run_installer.sh

# Run the installer, answer "yes" and ignore errors
RUN /tmp/run_installer.sh

# Your Roon data will be stored in /var/roon
VOLUME [ "/var/roon" ]

RUN mkdir -p /raat && \
    chown ${RAAT_USER} /raat && \
    echo 20200527 > /etc/hifiberry.version && \    
    echo 'CURRENT_MIXER_CONTROL="Digital"' > /etc/hifiberry.state && \
    echo > /raat/hifiberry_raat.conf && \
    chown ${RAAT_USER} /raat/hifiberry_raat.conf && \
    ln -s /raat/hifiberry_raat.conf /etc/hifiberry_raat.conf && \
    touch /raat/uuid && \
    chown ${RAAT_USER} /raat/uuid && \
    ln -s /raat/uuid /etc/uuid


ENV HOME /raat
WORKDIR /raat
USER ${RAAT_USER}
VOLUME /raat
ENTRYPOINT /opt/RoonBridge/start.sh

FROM ubuntu
RUN  apt-get update \
    && apt-get install -y wget \
    && rm -rf /var/lib/apt/lists/*
COPY ./favicon.sh /
RUN chmod +x /favicon.sh
ENTRYPOINT ["/favicon.sh"]
CMD [ "https://skillfactory.ru" ]
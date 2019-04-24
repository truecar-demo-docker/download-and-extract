FROM alpine

RUN apk add --update curl unzip tar py-pip bash

RUN pip install awscli

COPY download-and-extract.sh /bin/download-and-extract

CMD /bin/download-and-extract

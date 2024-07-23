FROM python:3.10.10-buster

ARG http_proxy="http://myproxy" \
    https_proxy="http://myproxy"

RUN apt-get update \
    && apt install g++ -y \
    && apt install libglib2.0-dev -y \
    && apt install libgl1-mesa-glx -y \
    && apt install libsm6 -y \
    && apt install libxrender1 -y

ADD requirements.txt /requirements.txt

RUN pip install -r /requirements.txt

ARG http_proxy="" \
    https_proxy=""

ADD PaddleOCR /PaddleOCR

WORKDIR /PaddleOCR

RUN hub install deploy/hubserving/kie_ser_re/ \
    && hub install deploy/hubserving/ocr_system/ \
    && hub install deploy/hubserving/ocr_cls/ \
    && hub install deploy/hubserving/ocr_det/ \
    && hub install deploy/hubserving/ocr_rec/

RUN rm -rf /root/.cache/* \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /app/test/pg/*

EXPOSE 8866

CMD ["/bin/bash","-c","hub serving start --modules kie_ser_re ocr_system ocr_cls ocr_det ocr_rec -p 8866 --use_multiprocess --workers=4"]
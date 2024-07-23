FROM registry.baidubce.com/paddlepaddle/paddle:3.0.0b1

ADD PaddleOCR /PaddleOCR

WORKDIR /PaddleOCR

ARG http_proxy="http://myproxy" \
    https_proxy="http://myproxy"

# protobuf requires 3.20.x or lower version
RUN pip install protobuf~=3.20 \
    && pip install paddlehub --upgrade \
    && pip install -r requirements.txt

# 直接使用阿里云的源
# RUN pip install protobuf~=3.20 -i https://mirror.aliyun.com/pypi/simple \
#     && pip install paddlehub --upgrade -i https://mirror.aliyun.com/pypi/simple \
#     && pip install -r requirements.txt -i https://mirror.aliyun.com/pypi/simple

ENV http_proxy=
ENV https_proxy=

EXPOSE 8866

CMD ["/bin/bash","-c","hub install /PaddleOCR/deploy/hubserving/kie_ser_re/ && hub serving start -m kie_ser_re"]
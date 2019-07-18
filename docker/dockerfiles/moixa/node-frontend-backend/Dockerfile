FROM mhart/alpine-node:12

RUN apk add --no-cache bash curl git grep jq py-pip screen unzip gawk \
    && pip install --upgrade awscli setuptools pyyaml \
    && yarn global add serverless typescript \
    && yarn cache clean

CMD ["/bin/sh"]

FROM gitlab/gitlab-ce:10.8.3-ce.0

RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    g++ \
    make \
    cmake \
    pkg-config \
    libmysqlclient-dev \
    ruby-mysql \
    mysql-client \
    gcc \
    cron
# # 添加构建所需头文件
# COPY include /opt/gitlab/embedded/include

RUN ruby -v
RUN curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
RUN curl -L get.rvm.io | bash -s stable
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install 2.4.1"
RUN ruby -v
RUN gem install mysql2 -v '0.4.10' -- --with-mysql-lib=/usr/lib64/mysql
# RUN gem install charlock_holmes -v '0.7.5'
# RUN apt-get install -yq libpq-dev
# RUN env ARCHFLAGS="-arch x86_64" gem install pg -v '0.18.4' -- --with-pg-config=`which pg_config`
RUN cd /opt/gitlab/embedded/service/gitlab-rails && \
    rm -rf .bundle/config && \
    bundle install --deployment --without development test aws kerberos
COPY entrypoint.sh .
# 配置自定义的oauth2认证
COPY customize_oauth.rb /opt/gitlab/embedded/service/gitlab-rails/config/initializers/
CMD [ "bash","entrypoint.sh" ]
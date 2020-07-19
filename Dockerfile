FROM ubuntu

# ONDREJ PHP E NGINX 

RUN apt-get update --fix-missing && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:ondrej/php
RUN add-apt-repository -y ppa:ondrej/nginx

RUN apt-get -y install php7.4-fpm php7.4-common php7.4-curl php7.4-intl php7.4-gd php7.4-dev php7.4-json php7.4-mbstring php7.4-mysql php7.4-opcache php7.4-xml php7.4-zip
RUN apt-get -y install nginx

# PHP CONFIG
ADD ./php/php.ini /etc/php/7.4/fpm/
ADD ./php/www.conf /etc/php/7.4/fpm/pool.d/

# NGINX CONFIG
RUN rm -r /etc/nginx/sites-enabled
ADD ./nginx/ADD /etc/nginx

# NEWRELIC (https://docs.newrelic.com/docs/agents/php-agent/installation/php-agent-installation-ubuntu-debian#unattended)

# RUN echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | tee /etc/apt/sources.list.d/newrelic.list
# RUN curl https://download.newrelic.com/548C16BF.gpg | apt-key add -
# RUN apt-get -y update
# RUN echo newrelic-php5 newrelic-php5/application-name string "My App Name" | debconf-set-selections
# RUN echo newrelic-php5 newrelic-php5/license-key string "YOUR_LICENSE_KEY" | debconf-set-selections
# RUN DEBIAN_FRONTEND=noninteractive apt-get -y install newrelic-php5
# RUN newrelic-install install # TEM Q TESTAR MAS ACHO ESSA LINHA NAO EH NECESSARIA

# git
RUN apt -y install git

# COMPOSER
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && php composer-setup.php && rm composer-setup.php && mv composer.phar /usr/local/bin/composer && chmod a+x /usr/local/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER 1

# drush 10.3.1
RUN git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
WORKDIR /usr/local/src/drush
RUN git checkout 10.3.1
RUN ln -s /usr/local/src/drush/drush /usr/bin/drush

# drupal console
WORKDIR /home
RUN curl https://drupalconsole.com/installer -L -o drupal.phar
RUN mv drupal.phar /usr/local/bin/drupal
RUN chmod +x /usr/local/bin/drupal

# nodejs 12.x
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install -y nodejs

# yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update && apt -y install yarn

# PROJECT HOME
WORKDIR /var/www/
# RUN git clone https://<seu usuario>:<sua senha>@bitbucket.org/<usuario dono do repositório>/<nome do repositório> <nome da aplicação>

# START

EXPOSE 9000 80

ADD ./init/ /
RUN chmod a+x /iniciar.sh

CMD /iniciar.sh

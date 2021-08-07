# NAME:     bamzooka/bamzooka_test
# VERSION:  release
ARG tag=build
FROM bamzooka/base:$tag
ENV RAILS_ENV test


# configure Git to suppress warnings
RUN sudo -E -u bamzooka -H git config --global user.email "you@example.com" &&\
    sudo -E -u bamzooka -H git config --global user.name "Your Name"

RUN gem update bundler --force &&\
      cd /var/www/bamzooka &&\
      chown -R bamzooka . &&\
      rm -fr .bundle &&\
      sudo -u bamzooka git pull &&\
      sudo -u bamzooka bundle install --standalone --jobs=4

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &&\
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list &&\
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - &&\
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list &&\
    apt update &&\
    apt install -y libgconf-2-4 libxss1 google-chrome-stable yarn nodejs &&\
    npm install -g eslint babel-eslint &&\
    cd /var/www/bamzooka && sudo -E -u bamzooka -H yarn install

#RUN cd /var/www/bamzooka && sudo -E -u bamzooka -H bundle exec rake plugin:install_all_official &&\
    #sudo -E -u bamzooka -H bundle exec rake plugin:install_all_gems &&\
RUN    chown -R bamzooka /var/run/postgresql

WORKDIR /var/www/bamzooka
ENV LANG en_US.UTF-8
ENTRYPOINT sudo -E -u bamzooka -H ruby script/docker_test.rb

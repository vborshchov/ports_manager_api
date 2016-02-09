web: bundle exec thin start -R config.ru -a $APP_URL -p $APP_PORT -e production
worker: bundle exec sidekiq -e production
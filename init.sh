cp app_sub/20210110044317_create_albuminfos.rb /myapp/db/migrate/
cp app_sub/database.yml /myapp/config/
cp app_sub/seeds.rb /myapp/db/

cp app_sub/application.css app/assets/stylesheets/
cp app_sub/application.js app/assets/javascripts/
cp app_sub/routes.rb config/

ln -s $JACKET_PATH /myapp/public/jackets

rake db:create
rake db:migrate
rake db:seed


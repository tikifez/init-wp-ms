#!/bin/bash
if [ "$#" -gt 0 ]
  then
  if [ "$#" -lt 6 ]
    then
    echo "Please include all parameters.\
    wp_dir, db_host, db_user, db_pass, db_name, wp_domain"
    exit 1
  else
    wp_dir=$1
    db_host=$2
    db_user=$3
    db_pass=$4
    db_name=$5
    wp_domain=$6
  fi
else
  echo "Site directory: "
  read wp_dir

  echo "Site domain name: "
  read wp_domain

  echo "Database host (e.g. localhost, or localhost:3311): "
  read db_host

  echo "Database user: "
  read db_user

  echo "Database password: "
  read db_pass

  echo "Database name: "
  read db_name

fi

echo "Installing WordPress into $wp_dir"

echo "** Initializing the repository"
mkdir $wp_dir && cd $wp_dir
git init
touch README.md
git add README.md
git commit -m "Initial commit."

echo "** Cloning WordPress as a subrepository"
git submodule add git://github.com/WordPress/WordPress.git wordpress
git commit -m "Add WordPress subrepository."

echo "** Checking out WordPress v.3.9"
cd wordpress
git checkout 3.9
cd ..
git commit -am "Checkout WordPress 3.9"

echo "** Creating wp-config file"
cp wordpress/wp-config-sample.php wp-config.php
git add wp-config.php
git commit -m "Adding default wp-config.php file"

echo "** Setting up wp-content directory"
cp -R wordpress/wp-content .
git add wp-content
git commit -m "Adding default wp-content directory"

echo "** Creating index.php"
cp wordpress/index.php .
git add index.php
git commit -m "Adding index.php"

echo "** Configuring core and site locations"
sed -i '' 's/\/wp-blog-header.php/\/wordpress\/wp-blog-header.php/g' index.php
git commit -am "Pointing index.php to the correct location"

echo "** Setting up database"
sed -i '' "s/database_name_here/$db_name/" wp-config.php
sed -i '' "s/username_here/$db_user/" wp-config.php
sed -i '' "s/password_here/$db_pass/" wp-config.php
sed -i '' "s/localhost/$db_host/" wp-config.php

echo "** Setting up keys"
COUNTER=0
while [  $COUNTER -lt 8 ]; do
  sed -i '' "1,/put your unique phrase here/s/put your unique phrase here/`LC_CTYPE=C tr -cd '[:alnum:]' < /dev/urandom | fold -w69 | head -n1`/" wp-config.php

  let COUNTER=COUNTER+1
done

echo "** Adding site location to wp-config"
echo "..."
var = "define('WP_SITEURL', 'http://' . $_SERVER['SERVER_NAME'] . '/$wp_dir/wordpress');\
define('WP_HOME',    'http://' . $_SERVER['SERVER_NAME'] . '/$wp_dir');\
\ ";
sed -i '' "16 a\
$var" wp-config.php
git commit -am "Update settings in wp-config.php"

echo "** Adding multisite options"
echo "..."
multisite_config="\\
\/* Multisite *\/\\
define( 'WP_ALLOW_MULTISITE', true );\
\\
/* Multisite Config */\\
// Uncomment the lines below after you've entered
define('MULTISITE', true);\\
define('SUBDOMAIN_INSTALL', false);\\
define('DOMAIN_CURRENT_SITE', '$wp_domain');\\
define('PATH_CURRENT_SITE', '/$wp_dir/wordpress/');\\
define('SITE_ID_CURRENT_SITE', 1);\\
define('BLOG_ID_CURRENT_SITE', 1);\\
\\
\ ";
sed -i '' "16 a\\
$multisite_config" wp-config.php

echo "** Creating .htaccess"
echo "..."
cat <<EOF > .htaccess
RewriteEngine On
RewriteBase /$wp_dir/wordpress/
RewriteRule ^index\.php$ - [L]

# add a trailing slash to /wp-admin
RewriteRule ^([_0-9a-zA-Z-]+/)?wp-admin$ \$1wp-admin/ [R=301,L]

RewriteCond %{REQUEST_FILENAME} -f [OR]
RewriteCond %{REQUEST_FILENAME} -d
RewriteRule ^ - [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(wp-(content|admin|includes).*) \$2 [L]
RewriteRule ^([_0-9a-zA-Z-]+/)?(.*\.php)$ \$2 [L]
RewriteRule . index.php [L]
EOF


echo "
** Processes done\\
**** Next steps: \\
**** 1. Set up your first blog at wordpress/wp-admin/install.php\\
**** 2. Enable multisite at Tools > Network Setup (wordpress/wp-admin/network.php)\\
**** 3. Uncomment the multisite lines (around lines 21-26) in wp-config.php"

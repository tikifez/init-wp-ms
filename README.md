# init-wp-ms
A shell script which automates a multisite WordPress install. 

WordPress is pulled from the WordPress github repo and core is installed to it's own directory.

Please note it's not 100% automated yet. There are a few steps which must be taken after the script is complete.


## Usage
Arguments are optional. If no arguments are given it will query the user for the required information.
```
./wp-single.sh install_dir db_server db_user db_pass db_name wp_domain_name
```

### Next steps
1. Complete the install by setting up your blog (wordpress/wp-admin/install.php)
* Enable multisite at Tools > Network Setup (wordpress/wp-admin/network.php)
* Uncomment the multisite lines (around lines 21-26) in wp-config.php"
  This is necessary because if the lines are uncommented before multisite has been enabled in Tools > Network Setup a database access error will be thrown by WordPress. 

## Thanks
This script was based on David Winter's excellent instructions for managing a WP install via git, located at [Install and manage WordPress with Git](http://davidwinter.me/articles/2012/04/09/install-and-manage-wordpress-with-git), accessible [via the WayBack machine](http://davidwinter.me/articles/2012/04/09/install-and-manage-wordpress-with-git)

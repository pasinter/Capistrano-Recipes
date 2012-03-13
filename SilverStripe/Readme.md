Capistrano Recipes for Silverstripe (www.silverstripe.org)
======


Requirements
-----------------
None

Assumptions
-----------------
Silverstripe library is located in the `silverstripe` directory

Available Tasks
-----------------
* `silverstripe:dev:build` - Build/rebuild this environment. Call this whenever you have updated your project sources
* `silverstripe:dev:buildcache` - Rebuild the static cache, if you're using StaticPublisher
* `silverstripe:cache:clear` - Clear cache files
* `silverstripe:cache:fix_perms` - Fix permissions on your cache files

* `silverstripe:deploy:setup` - Silverstripe specific setup
* `silverstripe:deploy:symlink_shared` - Create shared symlinks


Usage
-----------------
````
require 'SilverStripe/silverstripe.rb'

# run silverstripe specific setup
after 'deploy:setup', 'silverstripe:deploy:setup'

# run dev/build after code update
after "deploy:update_code", "silverstripe:dev:build"

# create shared symlink's
after "deploy:update_code", "deploy:symlink_shared"
````
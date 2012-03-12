Capistrano Recipes for Magento
======


Requirements
-----------------
None

Available Tasks
-----------------
* mage:cacheclear - Clears the cache
* mage:reindex - Rebuilds Magento indexes & cache
* mage:setup - Creates Magento specific shared directories
* mage:finalize_update - Magento specific finalize update tasks

Usage
-----------------
````
require 'Magento/magento.rb'

after "deploy:finalize_update", "mage:reindex"
after 'deploy:setup', 'mage:setup'
after 'deploy:finalize_update', 'mage:finalize_update'
````
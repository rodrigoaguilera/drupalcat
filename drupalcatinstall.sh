#!/bin/bash
# Get the repo root dir as a reference.
export REPO_DIR=$(git rev-parse --show-toplevel 2> /dev/null)
echo $REPO_DIR

# Make sure there is no docroot.
chmod -R 777 $REPO_DIR/docroot
rm -rf $REPO_DIR/docroot
# Download drupal core and contrib modules.
drush -y make $REPO_DIR/drupalcat.make $REPO_DIR/docroot
if [ -f $REPO_DIR/local.make ] ; then
  drush make --working-copy --no-core local.make $REPO_DIR/docroot
fi
# Place install profile to the docroot. Is preferable to use soft links so you
# don't have two copies of the same code.
ln -s $REPO_DIR/drupalcat $REPO_DIR/docroot/profiles/
# Symlink also settings.php
ln -s $REPO_DIR/settings.php $REPO_DIR/docroot/sites/default/
ln -s $REPO_DIR/settings.local.php $REPO_DIR/docroot/sites/default/
# Install the site.
cd $REPO_DIR/docroot
drush -y site-install  --locale=ca --account-pass=admin drupalcat
# login as admin after the install.
drush uli
# Capture configuration just after the install so we can diff our changes.
drush -y config-export
# Enable useful modules for development.
drush -y en field_ui config menu_ui views_ui
# Execute additional custom scripts. for example enable devel
if [ -f $REPO_DIR/local.sh ] ; then
  $REPO_DIR/local.sh
fi
# Back to the initial dir.
cd -

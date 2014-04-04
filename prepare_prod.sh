#!/bin/sh

cd ~/cartodb20
   
export RAILS_ENV=production
echo $RAILS_ENV

rvm use 1.9.2@cartodb --create && bundle install
rake assets:clean
rake tmp:clear 
rake tmp:create
rake assets:precompile

SUBDOMAIN=domain
PASSWORD=xxxx
ADMIN_PASSWORD=xxxx
EMAIL=valid@email.com

if test -n "$1"; then
	SUBDOMAIN="$1"
else
	echo -n "Enter a subdomain: "; read SUBDOMAIN
fi

#echo -n "Enter a password (cleartext!): "; read PASSWORD
#echo -n "Enter an admin password (cleartext!): "; read ADMIN_PASSWORD
#echo -n "Enter an email: "; read EMAIL

echo "--- Creating databases"
bundle exec rake cartodb:db:setup SUBDOMAIN="${SUBDOMAIN}" \
	PASSWORD="${PASSWORD}" ADMIN_PASSWORD="${ADMIN_PASSWORD}" \
	EMAIL="${EMAIL}"
if test $? -ne 0; then exit 1; fi

# # Update your quota to 10GB
 echo "--- Updating quota to 10GB"
 bundle exec rake cartodb:db:set_user_quota["${SUBDOMAIN}",10240]
 if test $? -ne 0; then exit 1; fi

# # Allow unlimited tables to be created
# echo "--- Allowing unlimited tables creation"
# bundle exec rake cartodb:db:set_unlimited_table_quota["${SUBDOMAIN}"]
# if test $? -ne 0; then exit 1; fi

# # Allow user to create private tables in addition to public
 echo "--- Allowing private tables creation"
 bundle exec rake cartodb:db:set_user_private_tables_enabled["${SUBDOMAIN}",'true']
 if test $? -ne 0; then exit 1; fi

# # Set the account type
 echo "--- Setting cartodb account type"
 bundle exec rake cartodb:db:set_user_account_type["${SUBDOMAIN}",'[DEDICATED]']
 if test $? -ne 0; then exit 1; fi

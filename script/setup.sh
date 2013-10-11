#!/bin/sh

echo "Installing dependencies with cpanminus"
PERL_AUTOINSTALL=--defaultdeps LANG=C cpanm --installdeps --notest . < /dev/null

if [[ $(mysql -N -uroot -e "SELECT 1 FROM mysql.user WHERE user = 'intern'") -ne "1" ]]; then
  mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'intern'@'localhost' IDENTIFIED BY 'intern' WITH GRANT OPTION"
  echo "User intern@localhost (intern) created"
fi

mysqladmin -uroot drop intern_bookmark -f > /dev/null 2>&1
mysqladmin -uroot create intern_bookmark
echo "Database \"intern_bookmark\" created"
echo "Initializing \"intern_bookmark\""
mysql -uroot intern_bookmark < db/schema.sql

mysqladmin -uroot drop intern_bookmark_test -f > /dev/null 2>&1
mysqladmin -uroot create intern_bookmark_test
echo "Database \"intern_bookmark_test\" created"
echo "Initializing \"intern_bookmark_test\""
mysql -uroot intern_bookmark_test < db/schema.sql

echo "Done."

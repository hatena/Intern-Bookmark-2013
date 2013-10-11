package t::Intern::Bookmark::DBI::Factory;
use strict;
use warnings;
use utf8;

use lib 't/lib';

use parent 'Test::Class';

use Test::More;

use Test::Intern::Bookmark;

use Intern::Bookmark::DBI::Factory;

sub _use : Test(1) {
    use_ok 'Intern::Bookmark::DBI::Factory';
}

sub _dbconfig : Test(3) {
    my $dbfactory = Intern::Bookmark::DBI::Factory->new;
    my $db_config = $dbfactory->dbconfig('intern_bookmark');
    is $db_config->{user}, 'intern';
    is $db_config->{password}, 'intern';
    is $db_config->{dsn}, 'dbi:mysql:dbname=intern_bookmark_test;host=localhost';
}

sub _dbh : Test(1) {
    my $dbfactory = Intern::Bookmark::DBI::Factory->new;
    my $dbh = $dbfactory->dbh('intern_bookmark');
    ok $dbh;

}

sub _query_builder : Test(1) {
    my $dbfactory = Intern::Bookmark::DBI::Factory->new;
    my $builder = $dbfactory->query_builder;
    ok $builder;
}

__PACKAGE__->runtests;

1;

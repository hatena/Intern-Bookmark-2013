package Intern::Bookmark::Util;

use strict;
use warnings;
use utf8;

use Carp ();
use Sub::Name;

use DateTime;
use DateTime::Format::MySQL;

use Intern::Bookmark::Config;

sub datetime_from_db ($) {
    my $dt = DateTime::Format::MySQL->parse_datetime( shift );
    $dt->set_time_zone(config->param('db_timezone'));
    $dt->set_formatter( DateTime::Format::MySQL->new );
    $dt;
}

1;
__END__

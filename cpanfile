requires 'LWP::UserAgent';
requires 'Plack::Middleware::Session';

# ---- for framework ---
requires 'Carp';
requires 'JSON::XS';
requires 'JSON::Types';
requires 'Class::Accessor::Lite';
requires 'Class::Accessor::Lite::Lazy';
requires 'Class::Load';
requires 'Config::ENV';
requires 'Encode';
requires 'Exporter::Lite';
requires 'Guard';
requires 'HTTP::Status';
requires 'Hash::MultiValue';
requires 'Path::Class';
requires 'Router::Simple';
requires 'Sub::Name';
requires 'Text::Xslate';
requires 'Text::Xslate::Bridge::TT2Like';
requires 'Try::Tiny';
requires 'URI';
requires 'URI::QueryParam';
requires 'FormValidator::Lite';
requires 'Log::Minimal';

requires 'DateTime';
requires 'DateTime::Format::MySQL';

requires 'Plack';
requires 'Plack::Middleware::ReverseProxy';
requires 'Plack::Middleware::Scope::Container';

# ---- for DB ----
requires 'DBIx::Sunny';
requires 'SQL::NamedPlaceholder';
requires 'Scope::Container::DBI';
requires 'SQL::Maker';
requires 'DBD::mysql';

# ---- for server ----
requires 'Starlet';
requires 'Server::Starter';

requires 'Devel::KYTProf';

# ---- for test ----
on test => sub {
    requires 'Test::More';
    requires 'Test::Deep';
    requires 'Test::Exception';
    requires 'Test::Differences';
    requires 'Test::Class';
    requires 'Test::WWW::Mechanize::PSGI';
    requires 'String::Random';
    requires 'DBIx::RewriteDSN';
};

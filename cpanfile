requires 'String::CamelCase';
requires 'List::MoreUtils';
requires 'PPI::Document';
requires 'Spellunker';
requires 'Test::Builder::Module';
requires 'parent';
requires 'perl', '5.008005';

on configure => sub {
    requires 'CPAN::Meta';
    requires 'CPAN::Meta::Prereqs';
    requires 'Module::Build';
};

on test => sub {
    requires 'Path::Tiny';
    requires 'Test::More', '0.98';
};

package Test::Symbol::Spelling;
use 5.008005;
use strict;
use warnings;
use utf8;
use parent qw/Test::Builder::Module/;
use File::Spec::Functions qw/catfile/;
use File::ShareDir qw/dist_dir/;
use ExtUtils::Manifest qw/maniread/;
use List::MoreUtils qw/uniq/;
use PPI::Document;
use Lingua::Ispell qw/spellcheck/;
use String::CamelCase ();

our $VERSION = "0.01";
our @EXPORT  = qw(
    symbol_spelling_ok
    all_symbol_spelling_ok
    set_ispell_path
    add_word
    add_word_lc
    accept_word
    allow_compounds
    make_wild_guesses
    use_dictionary
    use_personal_dictionary
    ng_word
);
our $SYMBOL_SPELLING = __PACKAGE__->_init;

sub _init {
    my $class = shift;

    # Set ispell path as default
    unless ($Lingua::Ispell::path) {
        foreach my $path (
            '',
            '/usr/local/bin/',
            '/usr/local/sbin/',
            '/usr/bin/',
            '/opt/usr/bin/',
            '/opt/local/bin/',
        ) {
            my $ispell_path = $path . 'ispell';
            if (-e $ispell_path) {
                $Lingua::Ispell::path = $ispell_path;
            }
        }
    }

    Lingua::Ispell::allow_compounds(1);

    # register word
    my $dict_path = catfile(dist_dir("Test-Symbol-Spelling"), "dict.txt");
    open my $fh, '<', $dict_path;
    while (my $word = <$fh>) {
        Lingua::Ispell::accept_word($word);
    }
    close $fh;

    bless {
        builder  => __PACKAGE__->builder,
        ng_words => [],
    }, $class;
}

sub all_symbol_spelling_ok () {
    $SYMBOL_SPELLING->_all_symbol_spelling_ok;
}

sub symbol_spelling_ok ($) {
    my $file = shift;
    $SYMBOL_SPELLING->_symbol_spelling_ok($file);
}

sub _all_symbol_spelling_ok {
    my $self  = shift;
    my $files = $self->_list_up_files_from_manifest;

    $self->{builder}->plan(tests => scalar @$files);

    my $fail = 0;
    foreach my $file (@$files) {
        $self->_symbol_spelling_ok($file) or $fail++;
    }

    return $fail == 0;
}

sub _symbol_spelling_ok {
    my ($self, $file) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    $self->{builder}->ok($self->_check_symbol_spelling($file) == 0, $file);
}

sub _check_symbol_spelling {
    my ($self, $file) = @_;

    my $fail = 0;

    my %ng_words; # TODO not good?
    $ng_words{$_} = 1 for @{$SYMBOL_SPELLING->{ng_words}};

    my $names = $self->_extract_names($file);
    foreach my $name (@$names) {
        my @words = split /::/, $name; # for functions

        my @_words;
        for my $word (@words) {
            for my $split (String::CamelCase::wordsplit($word)) {
                my @split_by_number = $split =~ /(\w+?)(\d+)/g;
                if (@split_by_number) {
                    $split =~ s/(\w+?)(\d+)//g;
                    push @split_by_number, $split;
                    push @_words, @split_by_number;
                }
                else {
                    push @_words, $split;
                }
            }
        }

        @words = grep { $_ } @_words;

        for my $word (@words) {
            if (defined $ng_words{$word}) {
                $self->{builder}->diag("Detect NG word: $name ('$word' is NG word)");
                $fail++;
                next;
            }

            if (spellcheck($word)) {
                $self->{builder}->diag("Detect bad spelling: $name ('$word' is wrong)");
                $fail++;
                next;
            }
        };
    }

    return $fail;
}

sub _extract_names {
    my ($self, $file) = @_;

    my $document = PPI::Document->new($file);
    $document    = $self->_diet_PPI_doc($document);

    my @names;
    $document->find(
        sub {
            # package
            if ($_[1]->isa('PPI::Statement::Package')) {
                push @names, $_[1]->namespace;
            }

            # function
            elsif ($_[1]->isa('PPI::Statement::Sub')) {
                if (my $function_name = $_[1]->name) {
                    push @names, $function_name;
                }
            }

            # variable
            elsif (ref($_[1]) eq 'PPI::Token::Symbol') {
                my $symbol_type = quotemeta($_[1]->raw_type);
                (my $symbol = $_[1]->symbol) =~ s/^$symbol_type//;
                unless ($symbol =~ /::/) { # not evaluate variables as module name
                    push @names, $symbol;
                }
            }
        }
    );
    @names = uniq(@names);
    return \@names;
}

sub _diet_PPI_doc {
    my ($self, $document) = @_;

    my @surplus_tokens = (
        'Operator',  'Number', 'Comment', 'Pod',
        'BOM',       'Data',   'End',     'Prototype',
        'Separator', 'Quote',  'Whitespace', 'Structure',
    );

    foreach my $surplus_token (@surplus_tokens) {
        $document->prune("PPI::Token::$surplus_token");
    }

    return $document;
}

sub _list_up_files_from_manifest {
    my $self = shift;

    if ( not -f $ExtUtils::Manifest::MANIFEST ) {
        $self->{builder}->plan(skip_all => "$ExtUtils::Manifest::MANIFEST doesn't exist");
    }
    my $manifest = maniread();
    my @libs = grep { m!\Alib/.*\.pm\Z! } keys %{$manifest};
    return \@libs;
}

sub add_word ($) {
    my $word = shift;
    Lingua::Ispell::add_word($word);
}

sub add_word_lc ($) {
    my $word = shift;
    Lingua::Ispell::add_word_lc($word);
}

sub accept_word ($) {
    my $word = shift;
    Lingua::Ispell::accept_word($word);
}

sub set_ispell_path ($) {
    my $ispell_path = shift;
    $Lingua::Ispell::path = $ispell_path;
}

sub allow_compounds ($) {
    my $bool = shift;
    Lingua::Ispell::allow_compounds($bool);
}

sub make_wild_guesses ($) {
    my $bool = shift;
    Lingua::Ispell::make_wild_guesses($bool);
}

sub use_dictionary ($) {
    my $dictionaries = shift;
    Lingua::Ispell::use_dictionary($dictionaries);
}

sub use_personal_dictionary ($) {
    my $dictionaries = shift;
    Lingua::Ispell::use_personal_dictionary($dictionaries);
}

sub ng_word ($) {
    my $word = shift;
    push @{$SYMBOL_SPELLING->{ng_words}}, $word;
}

'songmu-san he';
__END__

=encoding utf-8

=head1 NAME

Test::Symbol::Spelling - It's new $module

=head1 SYNOPSIS

    use Test::Symbol::Spelling;

=head1 DESCRIPTION

Test::Symbol::Spelling is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut


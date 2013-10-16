package Test::Symbol::Spelling;
use 5.008005;
use strict;
use warnings;
use utf8;
use parent qw/Test::Builder::Module/;
use ExtUtils::Manifest qw/maniread/;
use List::MoreUtils qw/uniq/;
use PPI::Document;
use Spellunker;
use Lingua::Ispell;
use String::CamelCase ();

our $VERSION = "0.01";
our @EXPORT  = qw(
    symbol_spell_ok
    all_symbol_spell_ok
    set_ispell_path
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

    bless {
        builder => __PACKAGE__->builder,
    }, $class;
}

sub all_symbol_spell_ok () {
    $SYMBOL_SPELLING->_all_symbol_spell_ok;
}

sub symbol_spell_ok ($) {
    my $file = shift;
    $SYMBOL_SPELLING->_symbol_spell_ok($file);
}

sub _all_symbol_spell_ok {
    my $self  = shift;
    my $files = $self->_list_up_files_from_manifest;

    $self->{builder}->plan(tests => scalar @$files);

    my $fail = 0;
    foreach my $file (@$files) {
        $self->_symbol_spell_ok($file) or $fail++;
    }

    return $fail == 0;
}

sub _symbol_spell_ok {
    my ($self, $file) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $pid = fork();
    if ( defined $pid ) {
        if ( $pid != 0 ) {
            wait;
            return $self->{builder}->ok($? == 0, $file);
        }
        else {
            exit $self->_check_symbol_spell($file);
        }
    }
    else {
        die "failed forking: $!";
    }
}

sub _check_symbol_spell {
    my ($self, $file) = @_;

    my $fail = 0;
    my $spellunker = Spellunker->new();

    my $names = $self->_extract_names($file);
    foreach my $name (@$names) {
        my @words = split /::/, $name; # for functions

        my @_words;
        for my $word (@words) {
            for my $split (String::CamelCase::wordsplit($word)) {
                my @split_by_number = $split =~ /(\w+?)(\d+)/g;
                if (@split_by_number) {
                    push @_words, @split_by_number;
                }
                else {
                    push @_words, $split;
                }
            }
        }

        @words = grep { $_ } @_words;

        for my $word (@words) {
            unless ($spellunker->check_word($word)) {
                $self->{builder}->diag("Detect bad spelling: '$name'");
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

sub set_ispell_path ($) {
    my $ispell_path = shift;
    $Lingua::Ispell::path = $ispell_path;
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


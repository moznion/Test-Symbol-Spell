package Test::Symbol::Spell;
use 5.008005;
use strict;
use warnings;
use utf8;
use parent qw/Test::Builder::Module/;
use ExtUtils::Manifest qw/maniread/;
use List::MoreUtils qw/uniq/;
use PPI::Document;
use Spellunker;
use String::CamelCase ();

our $VERSION = "0.01";

our @EXPORT = qw/symbol_spell_ok/;

sub all_symbol_spell_ok () {
    my $builder = __PACKAGE__->builder;
    my $files   = _list_up_files_from_manifest($builder);

    $builder->plan(tests => scalar @$files);

    my $fail = 0;
    foreach my $file (@$files) {
        _symbol_spell_ok($builder, $file) or $fail++;
    }

    return $fail == 0;
}

sub symbol_spell_ok ($) {
    my $file = shift;
    return _symbol_spell_ok(__PACKAGE__->builder, $file);
}

sub _symbol_spell_ok {
    my ($builder, $file) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my $pid = fork();
    if ( defined $pid ) {
        if ( $pid != 0 ) {
            wait;
            return $builder->ok($? == 0, $file);
        }
        else {
            exit _check_naming($builder, $file);
        }
    }
    else {
        die "failed forking: $!";
    }
}

sub _check_naming {
    my ($builder, $file) = @_;

    my $fail = 0;
    my $spellunker = Spellunker->new();

    my $names = _extract_names($file);
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
                $builder->diag("Detect bad spelling: '$name'");
                $fail++;
                next;
            }
        };
    }

    return $fail;
}

sub _extract_names {
    my $file = shift;

    my $document = PPI::Document->new($file);
    $document    = _diet_PPI_doc($document);

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
    my $document = shift;

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
    my $builder = shift;

    if ( not -f $ExtUtils::Manifest::MANIFEST ) {
        $builder->plan(skip_all => "$ExtUtils::Manifest::MANIFEST doesn't exist");
    }
    my $manifest = maniread();
    my @libs = grep { m!\Alib/.*\.pm\Z! } keys %{$manifest};
    return \@libs;
}


'songmu-san he';
__END__

=encoding utf-8

=head1 NAME

Test::Symbol::Spell - It's new $module

=head1 SYNOPSIS

    use Test::Symbol::Spell;

=head1 DESCRIPTION

Test::Symbol::Spell is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut


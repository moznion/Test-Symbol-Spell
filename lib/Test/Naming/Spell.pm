package Test::Naming::Spell;
use 5.008005;
use strict;
use warnings;
use utf8;
use parent qw/Test::Builder::Module/;
use List::MoreUtils qw/uniq/;
use PPI::Document;
use Spellunker;

our $VERSION = "0.01";

our @EXPORT = qw/naming_ok/;

sub naming_ok ($) {
    my ($lib, $args) = @_;
    return _naming_ok(__PACKAGE__->builder, $lib);
}

sub _naming_ok {
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

    # TODO camel
    my $names = _extract_names($file);
    foreach my $name (@$names) {
        my @words = split /::/, $name; # for functions

        # for variables
        my @_words;
        for my $word (@words) {
            push @_words, split /_/, $word;
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
1;
__END__

=encoding utf-8

=head1 NAME

Test::Naming::Spell - It's new $module

=head1 SYNOPSIS

    use Test::Naming::Spell;

=head1 DESCRIPTION

Test::Naming::Spell is ...

=head1 LICENSE

Copyright (C) moznion.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

moznion E<lt>moznion@gmail.comE<gt>

=cut


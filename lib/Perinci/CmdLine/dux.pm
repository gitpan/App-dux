package Perinci::CmdLine::dux;
use Moo;
extends 'Perinci::CmdLine';

our $VERSION = '1.29'; # VERSION

sub run_subcommand {
    require Tie::Diamond;

    my $self = shift;

    # set `in` and `out` arguments for the dux function
    my $chomp = $self->{_meta}{"x.dux.strip_newlines"} // 1;
    tie my(@diamond), 'Tie::Diamond', {chomp=>$chomp} or die;
    $self->{_args}{in}  = \@diamond;
    $self->{_args}{out} = [];

    # set default output format from metadata, if specified and user has not
    # specified --format
    my $mfmt = $self->{_meta}{"x.dux.default_format"};
    if ($mfmt) {
        $self->format($mfmt) unless
            grep {/^--format/} @{ $self->{_orig_argv} }; # not a proper way, but will do for now
    }

    $self->SUPER::run_subcommand(@_);
}

sub format_and_display_result {
    my $self = shift;
    if ($self->{_res} && $self->{_res}[0] == 200) {
        # insert out to result, so it can be displayed
        $self->{_res}[2] = $self->{_args}{out};
    }
    $self->SUPER::format_and_display_result(@_);
}

1;
# ABSTRACT: Perinci::CmdLine subclass for dux cli



__END__
=pod

=head1 NAME

Perinci::CmdLine::dux - Perinci::CmdLine subclass for dux cli

=head1 VERSION

version 1.29

=head1 DESCRIPTION

This subclass sets `in` and `out` arguments for the dux function, and displays
the resulting `out` array.

=head1 SEE ALSO

L<Perinci::CmdLine>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


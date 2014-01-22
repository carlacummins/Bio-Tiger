package Bio::TIGER::Pattern;

# ABSTRACT: 

=head1 SYNOPSIS

   
=method 

=cut

use Moose;
use Data::Dumper;
use Array::Utils;

has 'site_list' => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has 'patterns' => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1 );
has 'unknowns' => ( is => 'rw', isa => 'ArrayRef', required => 1);

sub _build_patterns {
	my ( $self ) = @_;
	
	my @pats;
	foreach my $s ( @{ $self->site_list } ){
		push(@pats, $self->_site_pattern($s));
	}
	return \@pats;
}

sub _site_pattern {
	my ($self, $site) = @_;
	my @unknowns = @{$self->unknowns};
	
	my @s = split(//, $site);
	my (%bases, @order);
	foreach my $i ( 0 .. $#s ){
		my $base = $s[$i];
		unless($base ~~ @unknowns){
		    push( @{ $bases{$base} }, $i );
		    push( @order, $base ) unless ( $base ~~ @order );
	    }
	}
	
	my @pattern;
	foreach my $k ( @order ){
		push(@pattern, $bases{$k});
	}
	return \@pattern;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

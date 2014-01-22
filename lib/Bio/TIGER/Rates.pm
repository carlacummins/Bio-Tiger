package Bio::TIGER::Rates;

# ABSTRACT: 

=head1 SYNOPSIS

   
=method 

=cut

use Moose;
use Data::Dumper;
use Array::Utils;

has 'site' => ( is => 'rw', isa => 'Str', required => 1 );
has 'site_list' => ( is => 'rw', isa => 'ArrayRef', required => 1 );

sub site_rate {
	my ( $self ) = @_;
	my $site = $self->site;
	my @site_list = @{ $self->site_list };
	
	my ($total_rate, $total_sites);
	foreach my $s ( @site_list ){
		my $r  = $self->_compare($site, $s);
		if( defined $r ){
			$total_sites++;
			$total_rate += $r;
		}
	}
	return ($total_rate/$total_sites);
}

sub _compare {
	my ($self, $s_a, $s_b) = @_;
	
	my @site_a = @{ $s_a };
	my @site_b = @{ $s_b };
	
	my $total_subs;
	foreach my $set_b ( @site_b ){
		$total_subs++ if( $self->_is_subset( $set_b, \@site_a ) );
	}
	my $lb = scalar @site_b;
	return ($total_subs/$lb);
}

sub _is_subset {
	my ( $self, $set, $sos ) = @_;
	my @set_of_sets = @{ $sos };
	
	foreach my $set2 ( @set_of_sets ){
		my @diff = array_minus(@{$set}, @{$set2});
		return 1 if(@diff);
	}
	return 0;
}


no Moose;
__PACKAGE__->meta->make_immutable;
1;

package Bio::TIGER;

# ABSTRACT: 

=head1 SYNOPSIS

   
=method 

=cut

use Moose;

use Bio::TIGER::Rates;

has 'file' => ( is => 'rw', isa => 'Str', required => 1 );
has '_alignment' => ( is => 'rw', isa => 'HashRef', lazy_build => 1, required => 0 );
has '_aln_order' => ( is => 'rw', isa => 'ArrayRef', required => 0 );
has '_columns' => ( is => 'rw', isa => 'ArrayRef', lazy_build => 1, required => 0 );

# START:
# Build internal data structures

sub _build__alignment {
	my ( $self ) = @_;
	my $file = $self->file;
	
	open(IN, "<", $file) or die "Could not find file: $file\n";
	my ( %aln, $current, @order );
	while(my $line = <IN>){
		chomp $line;
		if( $line =~ /^>/ ){
			$current = $line;
			$current =~ s/>//;
			$aln{$current} = '';
			push(@order, $current);
		}
		else {
			$aln{$current} .= $line;
		}
	}
	$self->_aln_order(\@order);
	return \%aln if $self->_validate_aln(\%aln);
}

sub _build__columns {
	my ( $self ) = @_;
	my %aln = %{ $self->_alignment };
	
	my @keys = keys %aln;
	my $l = length( $aln{ $keys[0] } );
	my @cols;
	foreach my $i ( 0..$l ){
		my $c = '';
		foreach my $j ( @keys ){
			$c .= substr($aln{$j}, $i, 1);
		}
		push( @cols, $c );
	}
	return \@cols;
}

# END: 
# Build internal data structures

# START:
# User functions

sub rates {
	my ( $self ) = @_;
	my %aln = %{ $self->_alignment };
	my @cols = @{ $self->_columns };
	
	my $pattern_obj = Bio::TIGER::Pattern->new( site_list => @cols );
	my @patterns = $pattern_obj->patterns;
	
	my @patterns_no_site;
	my @rates;
	foreach my $s ( 0 .. $#patterns ){
		my $site = $patterns[$s];
		@patterns_no_site = @patterns[ 0 .. ( $s-1 ) ];
		push(@patterns_no_site, @patterns[ ($s+1) .. $#patterns ]);
		my $rate_obj = Bio::TIGER::Rates->new(
			site => $site,
			site_list => @patterns_no_site
		);
		push( @rates, $rate_obj->rates );
	}
	return \@rates;
}

# END:
# User functions

# START:
# Internal functions

sub _validate_aln {
	my ($self, $aln) = @_;
	
	my %lens;
	foreach my $k ( keys %{ $aln } ){
		$lens{ length( $aln{$k} ) } = $k;
	}
	
	die "Sequences are not the same length\n" if ( scalar( keys %lens ) > 1 );
	return 1;
}

# END:
# Internal functions

no Moose;
__PACKAGE__->meta->make_immutable;
1;

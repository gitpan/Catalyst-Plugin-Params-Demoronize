package Catalyst::Plugin::Params::Demoronize;

use strict;
use warnings;

=head1 NAME

Catalyst::Plugin::Params::Demoronize - convert common UTF-8 and Windows-1252 characters to their ASCII equivalents

=head1 DESCRIPTION

to borrow a few passages from the documentation packaged
with john walker's demoronizer.pl:

=over 4

...as is usually the case when you encounter something
shoddy in the vicinity of a computer, Microsoft incompetence
and gratuitous incompatibility were to blame.  Western
language HTML documents are written in the ISO 8859-1
Latin-1 character set, with a specified set of escapes for
special characters.  Blithely ignoring this prescription, as
usual, Microsoft use their own "extension" to Latin-1, in
which a variety of characters which do not appear in Latin-1
are inserted in the range 0x82 through 0x95--this having the
merit of being incompatible with both Latin-1 and Unicode,
which reserve this region for additional control
characters.

These characters include open and close single and double
quotes, em and en dashes, an ellipsis and a variety of other
things you've been dying for, such as a capital Y umlaut and
a florin symbol.  Well, okay, you say, if Microsoft want to
have their own little incompatible character set, why not?
Because it doesn't stop there--in their inimitable fashion
(who would want to?)--they aggressively pollute the Web
pages of unknowing and innocent victims worldwide with these
characters, with the result that the owners of these pages
look like semi-literate morons when their pages are viewed
on non-Microsoft platforms (or on Microsoft platforms, for
that matter, if the user has selected as the browser's font
one of the many TrueType fonts which do not include the
incompatible Microsoft characters).

You see, "state of the art" Microsoft Office applications
sport a nifty feature called "smart quotes."  (Rule of
thumb--every time Microsoft use the word "smart," be on the
lookout for something dumb).  This feature is on by default
in both Word and PowerPoint, and can be disabled only by
finding the little box buried among the dozens of
bewildering option panels these products contain.  If
enabled, and you type the string,

    "Halt," he cried, "this is the police!"

"smart quotes" transforms the ASCII quote characters
automatically into the incompatible Microsoft opening and
closing quotes.  ASCII single and double quotes are
similarly transformed (even though ASCII already contains
apostrophe and single open quote characters), and double
hyphens are replaced by the incompatible em dash symbol.
What other horrors occur, I know not.  If the user notices
this happening at all, their reaction might be "Thank you
Billy-boy--that looks ever so much nicer," not knowing
they've been set up to look like a moron to folks all over
the world.

=back

these characters are commonly inserted into form elements
via cut and paste operations.  in many cases, they are
converted to UTF-8 by the browser.  this plugin will replace
both the unicode characters AND the Windows-1252 characters
with sane ASCII equivalents.

=cut

use NEXT;
use Encode::ZapCP1252;

our $VERSION = '1.0';

=head1 METHODS

=over 4

=item add_to_menu

=cut

sub prepare_parameters
{
	my $c = shift;

	my $retval = $c->NEXT::prepare_parameters(@_);
	my $params = $c->req->params;

	foreach my $key (keys %$params) {
		my $ref = \$params->{$key};

		for (ref $$ref) {
			/^$/		&& do { $$ref = $c->_demoronize($$ref) };
			/^ARRAY$/	&& do { $$ref = [ map { $c->_demoronize($_) } @$$ref ] };
		}
	}
}

sub _demoronize
{
	my $c	= shift;
	my $str	= shift;

	zap_cp1252($str);

	$str =~ s/\xE2\x80\x9A/,/g;		# 82
	$str =~ s/\xE2\x80\x9E/,,/g;	# 84
	$str =~ s/\xE2\x80\xA6/.../g;	# 85

	$str =~ s/\xCB\x86/^/g;			# 88

	$str =~ s/\xE2\x80\x98/`/g;		# 91
	$str =~ s/\xE2\x80\x99/'/g;		# 92
	$str =~ s/\xE2\x80\x9C/"/g;		# 93
	$str =~ s/\xE2\x80\x9D/"/g;		# 94
	$str =~ s/\xE2\x80\xA2/*/g;		# 95
	$str =~ s/\xE2\x80\x93/-/g;		# 96
	$str =~ s/\xE2\x80\x94/-/g;		# 97

	$str =~ s/\xE2\x80\xB9/</g;		# 8B
	$str =~ s/\xE2\x80\xBA/>/g;		# 9B

	return $str;
}

=back

=head1 AUTHOR

Mike Eldridge <diz@cpan.org>

=cut

1;


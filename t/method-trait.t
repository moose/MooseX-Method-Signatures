use strict;
use warnings;
use Test::More 0.88;
use Test::Moose;

{
    package Bar;
    use Moose::Role;
    BEGIN { $INC{'Bar.pm'} = 1; }
}

{
    package Baz;
    use Moose::Role;
    BEGIN { $INC{'Baz.pm'} = 1; }
}

{
    package Foo;

    use Moose;
    use MooseX::Method::Signatures;

    BEGIN { $INC{'Foo.pm'} = 1; }

    method bar ($baz) does Bar { $baz }
    method bla ($baz) does Bar does Baz { $baz }
    method boo ($baz) does (Bar, Baz) { $baz }

}

my $o = Foo->new;

can_ok($o, 'bar');
my $method = Foo->meta->get_method('bar');
does_ok($method, 'Bar');

can_ok($o, 'bla');
$method = Foo->meta->get_method('bla');
does_ok($method, 'Bar');
does_ok($method, 'Baz');

can_ok($o, 'boo');
$method = Foo->meta->get_method('boo');
does_ok($method, 'Bar');
does_ok($method, 'Baz');

done_testing;

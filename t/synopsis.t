use strict;
use warnings;
use Test::More;
use Test::Fatal;

{
    package Foo;
    use Moose;
    use MooseX::Method::Signatures;

    method morning (Str $name) {
        return "Good morning ${name}!";
    }

    method hello (Str :$who, Int :$age where { $_ > 0 }) {
        return "Hello ${who}, I am ${age} years old!";
    }

    method greet (Str $name, Bool :$excited = 0) {
        if ($excited) {
            return "GREETINGS ${name}!";
        }
        else {
            return "Hi ${name}!";
        }
    }

    package SomeClass;
    use Moose;
    use MooseX::Method::Signatures;

    method foo ( SomeClass $thing where { $_->can('stuff') }:
                 Str  $bar  = "apan",
                 Int :$baz! = 42 where { $_ % 2 == 0 } where { $_ > 10 } ) { return $bar . ':' . $baz }

    method stuff { }

    # the invocant is called $thing, must be an instance of SomeClass and
    #       has to implement a 'stuff' method
    # $bar is positional, required, must be a string and defaults to "apan"
    # $baz is named, required, must be an integer, defaults to 42 and needs
    #      to be even and greater than 10
}

my $foo = new_ok('Foo');

is(exception { is $foo->morning('Resi'), 'Good morning Resi!' }, undef, 'positional str arg');
is(exception { is $foo->hello(who => 'world', age => 42), 'Hello world, I am 42 years old!' }, undef, 'two named args');
is(exception { is $foo->greet('Resi', excited => 1), 'GREETINGS Resi!' }, undef, 'positional and named args (with named default)');
is(exception { is $foo->greet('Resi'), 'Hi Resi!' }, undef, 'In else Branch (excited 0): positional and named args (with named default)');
like(exception { $foo->hello(who => 'world', age => 'fortytwo') }, qr/Validation failed/, 'Str, Str sent to Str, Int');
like(exception { $foo->hello(who => 'world', age => -23) }, qr/Validation failed/, 'Int violates where');
like(exception { $foo->morning }, qr/Validation failed/, 'no required (positional) arg passed');
like(exception { $foo->greet }, qr/Validation failed/, 'no required (positional) arg passed');

my $someclass = new_ok('SomeClass');

is(exception { is $someclass->foo, 'apan:42' }, undef, '$someclass->foo');
is(exception { is $someclass->foo('quux'), 'quux:42' }, undef, '$someclass->foo("quux")');
is(exception { is $someclass->foo('quux', baz => 12), 'quux:12' }, undef, '$someclass->foo("quux", baz => 12)');

like(exception { $someclass->foo(baz => 12) }, qr/Expected named arguments/, '$someclass->foo(baz => 12)');
like(exception { $someclass->foo(baz => 12, 'quux') }, qr/Validation failed/, '$someclass->foo(baz => 12, "quux")');
like(exception { $someclass->foo(baz => 41) }, qr/Expected named arguments/, '$someclass->foo(baz => 41)');
like(exception { $someclass->foo(baz => 44) }, qr/Expected named arguments/, '$someclass->foo(baz => 12)');


done_testing;

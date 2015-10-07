package MooseX::Method::Signatures::Types;
#ABSTRACT: (DEPRECATED) Provides common MooseX::Types used by MooseX::Method::Signatures

our $VERSION = '0.50';

use MooseX::Types 0.19 -declare => [qw/ Injections PrototypeInjections Params /];
use MooseX::Types::Moose qw/Str ArrayRef/;
use MooseX::Types::Structured 0.24 qw/Dict/;
use Parse::Method::Signatures::Types qw/Param/;
use if MooseX::Types->VERSION >= 0.42, 'namespace::autoclean';

subtype Injections,
    as ArrayRef[Str];

subtype PrototypeInjections,
    as Dict[declarator => Str, injections => Injections];

subtype Params,
    as ArrayRef[Param];

1;

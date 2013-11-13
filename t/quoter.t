use strict;
use warnings;

use Test::More;

use SQL::Builder::Quoter;

subtest 'quote simple column' => sub {
    my $quoter = SQL::Builder::Quoter->new();

    is $quoter->quote('foo'), '`foo`';
};

subtest 'quote column with table' => sub {
    my $quoter = SQL::Builder::Quoter->new();

    is $quoter->quote('table.foo'), '`table`.`foo`';
};

subtest 'quote column with custom quote char' => sub {
    my $quoter = SQL::Builder::Quoter->new(quote_char => '"');

    is $quoter->quote('table.foo'), '"table"."foo"';
};

subtest 'quote column with custom name separator' => sub {
    my $quoter =
      SQL::Builder::Quoter->new(quote_char => '"', name_separator => ':');

    is $quoter->quote('table:foo'), '"table":"foo"';
};

done_testing;
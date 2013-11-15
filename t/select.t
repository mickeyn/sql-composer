use strict;
use warnings;

use Test::More;

use SQL::Builder::Select;

subtest 'build simple' => sub {
    my $expr =
      SQL::Builder::Select->new(from => 'table', columns => ['a', 'b']);

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `table`.`a`,`table`.`b` FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];

    is_deeply $expr->from_rows([['c', 'd']]), [{a => 'c', b => 'd'}];
};

subtest 'build column as' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => [{-col => 'foo' => -as => 'bar'}]
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `table`.`foo` AS `bar` FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];

    is_deeply $expr->from_rows([['c']]), [{bar => 'c'}];
};

subtest 'build column as is' => sub {
    my $expr =
      SQL::Builder::Select->new(from => 'table', columns => [\'COUNT(*)']);

    my $sql = $expr->to_sql;
    is $sql, 'SELECT COUNT(*) FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];

    is_deeply $expr->from_rows([['c']]), [{'COUNT(*)' => 'c'}];
};

subtest 'build column as with as is' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => [{-col => \'COUNT(*)', -as => 'count'}]
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT COUNT(*) AS `count` FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];

    is_deeply $expr->from_rows([['c']]), [{'count' => 'c'}];
};

subtest 'build with where' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        where   => [a => 'b']
    );

    my $sql = $expr->to_sql;
    is $sql,
      'SELECT `table`.`a`,`table`.`b` FROM `table` WHERE `table`.`a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b'];
};

subtest 'build with group_by' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        group_by => 'a'
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `table`.`a`,`table`.`b` FROM `table` GROUP BY `table`.`a`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with order by' => sub {
    my $expr = SQL::Builder::Select->new(
        from     => 'table',
        columns  => ['a', 'b'],
        order_by => 'foo'
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `table`.`a`,`table`.`b` FROM `table` ORDER BY `foo`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with order by with order' => sub {
    my $expr = SQL::Builder::Select->new(
        from     => 'table',
        columns  => ['a', 'b'],
        order_by => [foo => 'desc']
    );

    my $sql = $expr->to_sql;
    is $sql,
      'SELECT `table`.`a`,`table`.`b` FROM `table` ORDER BY `table`.`foo` DESC';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with order by multi' => sub {
    my $expr = SQL::Builder::Select->new(
        from     => 'table',
        columns  => ['a', 'b'],
        order_by => [foo => 'desc', bar => 'asc']
    );

    my $sql = $expr->to_sql;
    is $sql,
'SELECT `table`.`a`,`table`.`b` FROM `table` ORDER BY `table`.`foo` DESC,`table`.`bar` ASC';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with limit' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        limit   => 5
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `table`.`a`,`table`.`b` FROM `table` LIMIT 5';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with limit and offset' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        limit   => 5,
        offset  => 10
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `table`.`a`,`table`.`b` FROM `table` LIMIT 5 OFFSET 10';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with join' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a'],
        join => {source => 'table2', columns => ['b'], on => ['table.a' => '1']}
    );

    my $sql = $expr->to_sql;
    is $sql,
'SELECT `table`.`a`,`table2`.`b` FROM `table` JOIN `table2` ON `table`.`a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['1'];

    is_deeply $expr->from_rows([['c', 'd']]),
      [{a => 'c', table2 => {b => 'd'}}];
};

subtest 'build with join with alias' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a'],
        join => {source => 'table2', as => 'new_table2', columns => ['b'], on => ['table.a' => '1']}
    );

    my $sql = $expr->to_sql;
    is $sql,
'SELECT `table`.`a`,`new_table2`.`b` FROM `table` JOIN `table2` AS `new_table2` ON `table`.`a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['1'];

    is_deeply $expr->from_rows([['c', 'd']]),
      [{a => 'c', new_table2 => {b => 'd'}}];
};

subtest 'build with join and prefix' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a'],
        join    => {
            source  => 'table2',
            as      => 'new_table2',
            columns => ['b'],
            on      => ['table.a' => '1']
        }
    );

    my $sql = $expr->to_sql;
    is $sql,
'SELECT `table`.`a`,`new_table2`.`b` FROM `table` JOIN `table2` AS `new_table2` ON `table`.`a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['1'];

    is_deeply $expr->from_rows([['c', 'd']]),
      [{a => 'c', new_table2 => {b => 'd'}}];
};

subtest 'build with multiple joins' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        join    => [
            {source => 'table2', on => ['table.a' => 'b']},
            {source => 'table3', on => ['table.c' => 'd']}
        ]
    );

    my $sql = $expr->to_sql;
    is $sql,
'SELECT `table`.`a`,`table`.`b` FROM `table` JOIN `table2` ON `table`.`a` = ? JOIN `table3` ON `table`.`c` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b', 'd'];
};

subtest 'build with deep joins' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a'],
        join    => [
            {
                source  => 'table2',
                columns => ['b'],
                on      => [a => '1'],
                join    => [
                    {
                        source  => 'table3',
                        columns => ['c'],
                        on      => [b => '2']
                    }
                ]
            }
        ]
    );

    my $sql = $expr->to_sql;
    is $sql,
'SELECT `table`.`a`,`table2`.`b`,`table3`.`c` FROM `table` JOIN `table2` ON `table2`.`a` = ? JOIN `table3` ON `table3`.`b` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['1', '2'];

    is_deeply $expr->from_rows([['c', 'd', 'e']]),
      [{a => 'c', table2 => {b => 'd', table3 => {c => 'e'}}}];
};

done_testing;

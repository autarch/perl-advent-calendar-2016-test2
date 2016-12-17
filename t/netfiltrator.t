use strict;
use warnings;

use Test2::Bundle::Extended;

{
    package Grinch::Netfiltrator;
    use Moo;

    our @SERVERS;
    sub mock_servers { shift; @SERVERS = @_ }

    sub find_nile_servers {
        return \@SERVERS;
    }
}

Grinch::Netfiltrator->mock_servers(
    {
        hostname => 'www.nile.com',
        ip       => '1.2.3.4',
        ssh_port => 443,
    },
    {
        hostname => 'www2.nile.com',
        ip       => '1.2.3.5',
        ssh_port => 447,
    },
);

my $servers = Grinch::Netfiltrator->new->find_nile_servers;
is(
    $servers,
    array {
        item hash {
            field hostname => 'www.nile.com';
            field ip       => '1.2.3.4';
            field ssh_port => 443;
        };
        item hash {
            field hostname => 'www2.nile.com';
            field ip       => '1.2.3.5';
            field ssh_port => 447;
        };
    },
    'got the expected servers back'
);

is(
    $servers,
    array {
        item hash {
            field hostname => 'www.nile.com';
            field ip       => '1.2.3.4';
            field ssh_port => 443;
            end();
        };
        item hash {
            field hostname => 'www2.nile.com';
            field ip       => '1.2.3.5';
            field ssh_port => 447;
            end();
        };
        end();
    },
    'got the expected servers back'
);

{
    package Grinch::Server;
    use Moo;

    has [qw( hostname ip ssh_port ) ] => ( is => 'ro' );
}

Grinch::Netfiltrator->mock_servers(
    map { Grinch::Server->new($_) } (
        {
            hostname => 'www.nile.com',
            ip       => '1.2.3.4',
            ssh_port => 443,
        },
        {
            hostname => 'www2.nile.com',
            ip       => '1.2.3.5',
            ssh_port => 446,
        },
    )
);

is(
    $servers,
    array {
        item object {
            prop blessed  => 'Grinch::Server';
            call hostname => 'www.nile.com';
            call ip       => '1.2.3.4';
            call ssh_port => 443;
        };
        item object {
            prop blessed  => 'Grinch::Server::Hacked';
            call hostname => 'www2.nile.com';
            call ip       => '1.2.3.5';
            call ssh_port => 446;
        };
        end();
    },
    'got the expected servers back'
);

done_testing();

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
        ssh_port => 446,
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
            field ssh_port => 446;
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
            field ssh_port => 446;
            end();
        };
        end();
    },
    'got the expected servers back'
);

{
    package Grinch::Server;
    use Moo;

    has [qw( hostname ip ssh_port )] => ( is => 'ro' );
    sub ssh_ports { @{ $_[0]->ssh_port } }
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
            prop blessed  => 'Grinch::Server';
            call hostname => 'www2.nile.com';
            call ip       => '1.2.3.5';
            call ssh_port => 446;
        };
        end();
    },
    'got the expected servers back'
);

Grinch::Netfiltrator->mock_servers(
    map { Grinch::Server->new($_) } (
        {
            hostname => 'www.nile.com',
            ip       => '1.2.3.4',
            ssh_port => [ 443, 444 ],
        },
        {
            hostname => 'www2.nile.com',
            ip       => '1.2.3.5',
            ssh_port => [ 443 .. 446 ],
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
            call ssh_port => [ 443, 444 ];
        };
        item object {
            prop blessed  => 'Grinch::Server';
            call hostname => 'www2.nile.com';
            call ip       => '1.2.3.5';
            call ssh_port => [ 443 .. 446 ],
        };
        end();
    },
    'got the expected servers back'
);

is(
    $servers,
    array {
        item object {
            prop blessed        => 'Grinch::Server';
            call hostname       => 'www.nile.com';
            call ip             => '1.2.3.4';
            call_list ssh_ports => [ 443, 444 ];
        };
        item object {
            prop blessed        => 'Grinch::Server';
            call hostname       => 'www2.nile.com';
            call ip             => '1.2.3.5';
            call_list ssh_ports => [ 443 .. 446 ],
        };
        end();
    },
    'got the expected servers back'
);

is(
    $servers,
    array {
        item object {
            prop blessed        => 'Grinch::Server';
            call hostname       => match qr/\A\w+(?:\.\w+)+\z/;
            call ip             => '1.2.3.4';
            call_list ssh_ports => [ 443, 444 ];
        };
        item object {
            prop blessed        => 'Grinch::Server';
            call hostname       => match qr/\A\w+(?:\.\w+)+\z/;
            call ip             => '1.2.3.5';
            call_list ssh_ports => [ 443 .. 446 ],
        };
        end();
    },
    'got the expected servers back'
);

use Data::Validate::Domain qw( is_hostname );
my $hostname_check = validator( is_hostname => sub { is_hostname($_) } );

is(
    $servers,
    array {
        item object {
            prop blessed        => 'Grinch::Server';
            call hostname       => $hostname_check;
            call ip             => '1.2.3.4';
            call_list ssh_ports => [ 443, 444 ];
        };
        item object {
            prop blessed        => 'Grinch::Server';
            call hostname       => $hostname_check;
            call ip             => '1.2.3.5';
            call_list ssh_ports => [ 443 .. 446 ],
        };
        end();
    },
    'got the expected servers back'
);

done_testing();

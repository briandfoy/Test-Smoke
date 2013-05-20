package Test::Smoke::App::Options;
use warnings;
use strict;

use Test::Smoke::App::AppOption;

my $opt = 'Test::Smoke::App::AppOption';

sub syncer_config { # synctree.pl
    return (
        allow => [qw/git rsync copy/],
        default => 'git',
        general_options => [
            ddir(),
        ],
        special_options => {
            git  => [
                gitbin(),
                gitorigin(),
                gitdir(),
                gitdfbranch(),
                gitbranchfile(),
            ],
            rsync => [
                rsyncbin(),
                rsyncopts(),
                rsyncsource(),
            ],
            copy  => [
                cdir()
            ],
        },
    );
}

sub mailer_config { # mailrpt.pl
    return (
        allow => [qw/sendmail mail mailx sendemail Mail::Sendmail MIME::Lite/],
        default => 'Mail::Sendmail',
        general_options => [
            ddir(),
            to(),
            cc(),
            bcc(),
            ccp5p_onfail(),
            rptfile(),
            mail(),
            report(),
        ],
        special_options => {
            mail => [mailbin()],
            mailx => [mailxbin()],
            sendemail => [
                sendemailbin(),
                from(),
                mserver(),
                msport(),
                msuser(),
                mspass(),
            ],
            sendmail => [
                sendmailbin(),
                from(),
            ],
            'Mail::Sendmail' => [
                from(),
                mserver(),
                msport(),
            ],
            'MIME::Lite' => [
                from(),
                mserver(),
                msport(),
                msuser(),
                mspass(),
            ],
        },
    );
}

sub poster_config {
    return (
        allow => [qw/LWP::UserAgent HTTP::Lite/],
        general_options => [
            ddir(),
            smokedb_url(),
            jsnfile(),
            report(),
        ],
        special_options => {
            'LWP::UserAgent' => [
                ua_timeout(),
            ],
            'HTTP::Lite' => [],
        },
    );
}

sub reporter_config {
    return (
        general_options => [
            ddir(),
            outfile(),
            rptfile(),
            jsnfile(),
            lfile(),
            cfg(),
            showcfg(),
            locale(),
            defaultenv(),
            is56x(),
            skip_tests(),
            harnessonly(),
            harness3opts(),
            user_note(),
            un_file(),
            un_position(),
        ],
    );
}

sub sendreport_config {
    # merge: mailer_config, poster_config and reporter_config.
    my %mc = mailer_config();
    my $mail_type = $opt->new(
        name => 'mail_type',
        option => 'mailer=s',
        allow => $mc{allow},
        helptext => "The type of mailsystem to use.",
    );
    my %pc = poster_config();
    my $poster = $opt->new(
        name => 'poster',
        option => '=s',
        allow => $pc{allow},
        default => 'LWP::UserAgent',
        helptext => "The type of HTTP post system to use.",
    );
    my %rc = reporter_config();
    my %g_o;
    for my $opt ( @{$mc{general_options}}
                , @{$pc{general_options}}
                , @{$rc{general_options}})
    {
        $g_o{$opt->name} ||= $opt;
    }
    my %s_o;
    for my $so (keys %{$mc{special_options}}) {
        $s_o{$so} = $mc{special_options}{$so};
    }
    for my $so (keys %{$pc{special_options}}) {
        $s_o{$so} = $pc{special_options}{$so};
    }
    return (
        general_options => [$mail_type, $poster, values %g_o],
        special_options => \%s_o,
    );
}

sub smoker_config {
    return (
        general_options => [
            ddir(),
        ],
    );
}

sub ddir {
    return $opt->new(
        name => 'ddir',
        option => 'd=s',
        helptext => 'Directory where perl is smoked.',
    );
}

sub rptfile {
    return $opt->new(
        name => 'rptfile',
        option => '=s',
        default => 'mktest.rpt',
        helptext => 'Name of the file to store the email report in.',
    );
}

sub outfile {
    return $opt->new(
        name => 'outfile',
        option => '=s',
        default => 'mktest.out',
        helptext => 'Name of the file to store the email report in.',
    );
}

sub jsnfile {
    return $opt->new(
        name => 'jsnfile',
        option => '=s',
        default => 'mktest.jsn',
        helptext => 'Name of the file to store the JSON report in.',
    );
}

sub lfile {
    return $opt->new(
        name => 'lfile',
        option => '=s',
        default => undef,
        helptext => 'Name of the file to store the smoke log in.',
    );
}

sub mail {
    return $opt->new(
        name => 'mail',
        option => '!',
        helptext => "Send report via mail.",
    );
}

sub to {
    return $opt->new(
        name => 'to',
        option => '=s',
        default => 'daily-build-reports@perl.org',
        helptext => 'Where to send the reports.',
    );
}

sub cc {
    return $opt->new(
        name => 'cc',
        option => '=s',
        default => '',
        helptext => 'Where to send a cc of the reports.',
    );
}

sub bcc {
    return $opt->new(
        name => 'bcc',
        option => '=s',
        default => '',
        helptext => 'Where to send a bcc of the reports.',
    );
}

sub from {
    return $opt->new(
        name => 'from',
        option => '=s',
        default => '',
        helptext => 'Where to send the reports from.',
    );
}

sub mserver {
    return $opt->new(
        name => 'mserver',
        option => '=s',
        default => 'localhost',
        helptext => 'Which SMTP server to send reports.',
    );
}

sub msport {
    return $opt->new(
        name => 'msport',
        option => '=i',
        default => 25,
        helptext => 'Which port for SMTP server to send reports.',
    );
}

sub msuser {
    return $opt->new(
        name => 'msuser',
        option => '=s',
        helptext => 'Username for SMTP server.',
    );
}

sub mspass {
    return $opt->new(
        name => 'mspass',
        option => '=s',
        helptext => 'Password for <msuser> for SMTP server.',
    );
}

sub ccp5p_onfail {
    return $opt->new(
        name => 'ccp5p_onfail',
        option => '!',
        default => 0,
        helptext => 'Include the p5p-mailinglist in CC.',
    );
}

sub swcc {
    return $opt->new(
        name => 'swcc',
        option => '=s',
        default => '-c',
        helptext => 'The syntax of the commandline switch for CC.',
    );
}

sub swbcc {
    return $opt->new(
        name => 'swbcc',
        option => '=s',
        default => '-b',
        helptext => 'The syntax of the commandline switch for BCC.',
    );
}

sub mailbin {
    return $opt->new(
        name => 'mailbin',
        option => '=s',
        default => 'mail',
        helptext => "The name of the 'mail' program.",
    );
}

sub mailxbin {
    return $opt->new(
        name => 'mailxbin',
        option => '=s',
        default => 'mailx',
        helptext => "The name of the 'mailx' program.",
    );
}

sub sendemailbin {
    return $opt->new(
        name => 'sendemailbin',
        option => '=s',
        default => 'sendemail',
        helptext => "The name of the 'sendemail' program.",
    );
}

sub sendmailbin {
    return $opt->new(
        name => 'sendmailbin',
        option => '=s',
        default => 'sendmail',
        helptext => "The name of the 'sendmail' program.",
    );
}

sub gitbin {
    return $opt->new(
        name => 'gitbin',
        option => '=s',
        default => 'git',
        helptext => "The name of the 'git' program.",
    );
}

sub gitorigin {
    return $opt->new(
        name => 'gitorigin',
        option => '=s',
        default => 'git://perl5.git.perl.org/perl.git',
        helptext => "The remote location of the git repository.",
    );
}

sub gitdir {
    return $opt->new(
        name => 'gitdir',
        option => '=s',
        default => 'perl-git',
        helptext => "The local directory of the git repository.",
    );
}

sub gitdfbranch {
    return $opt->new(
        name => 'gitdfbranch',
        option => '=s',
        default => 'blead',
        helptext => "The name of the gitbranch you smoke.",
    );
}

sub gitbranchfile {
    return $opt->new(
        name => 'gitbranchfile',
        option => '=s',
        default => '',
        helptext => "The name of the file where the gitbranch is stored.",
    );
}

sub rsyncbin {
    return $opt->new(
        name => 'rsync', #old name
        option => '=s',
        default => 'rsync', # you might want a path there
        helptext => "The name of the 'rsync' programe.",
    );
}

sub rsyncopts {
    return $opt->new(
        name => 'opts',
        option => '=s',
        default => '-az --delete',
        helptext => "Options to use for the 'rsync' program",
    );
}

sub rsyncsource {
    return $opt->new(
        name => 'source',
        option => '=s',
        default => 'perl5.git.perl.org::perl-current',
        helptext => "The remote location of the rsync archive.",
    );
}

sub cdir {
    return $opt->new(
        name => 'cdir',
        option => '=s',
        helptext => "The local directory from where to copy the perlsources.",
    );
}

sub report {
    return $opt->new(
        name => 'report',
        option => '!',
        default => 0,
        helptext => "Force recreation of the report/json files.",
    );
}

sub smokedb_url {
    return $opt->new(
        name => 'smokedb_url',
        option => '=s',
        default => 'http://perl5.test-smoke.org/report',
        helptext => "The URL for sending reports to CoreSmokeDB.",
    );
}

sub ua_timeout {
    return $opt->new(
        name => 'ua_timeout',
        option => '=i',
        default => 30,
        helptext => "The timeout to set the UserAgent.",
    );
}

sub send_log {
    return $opt->new(
        name => 'send_log',
        option => '=s',
        default => 'on_fail',
        helptext => "Send logfile to the CoreSmokeDB server.",
    );
}

sub send_out {
    return $opt->new(
        name => 'send_out',
        option => '=s',
        default => 'never',
        helptext => "Send out-file to the CoreSmokeDB server.",
    );
}

sub cfg {
    return $opt->new(
        name => 'cfg',
        option => '=s',
        default => undef,
        helptext => "The name of the BuildCFG file.",
    );
}

sub showcfg {
    return $opt->new(
        name => 'showcfg',
        option => '!',
        default => 0,
        helptext => "Show a complete overview of all build configurations.",
    );
}

sub locale {
    return $opt->new(
        name => 'locale',
        option => '=s',
        helptext => "Choose a locale to run the test suite under.",
    );
}

sub defaultenv {
    return $opt->new(
        name => 'defaultenv',
        option => '!',
        default => 0,
        helptext => "Do not set the test suite environment to locale.",
    );
}

sub is56x {
    return $opt->new(
        name => 'is56x',
        option => '!',
        helptext => "Are we smoking perl maint-5.6?",
    );
}

sub skip_tests {
    return $opt->new(
        name => 'skip_tests',
        option => '=s',
        helptext => "Name of the file to store tests to skip.",
    );
}

sub harnessonly {
    return $opt->new(
        name => 'harnessonly',
        option => '!',
        default => 0,
        helptext => "Run test suite as 'make test_harness' (not make test).",
    );
}

sub harness3opts {
    return $opt->new(
        name => 'harness3opts',
        option => '=s',
        helptext => "Extra options to pass to harness v3+.",
    );
}

sub user_note {
    return $opt->new(
        name => 'user_note',
        option => '=s',
        helptext => "Extra text to insert into the smoke report.",
    );
}

sub un_file {
    return $opt->new(
        name => 'un_file',
        option => '=s',
        helptext => "Name of the file with the 'user_note' text.",
    );
}

sub un_position {
    return $opt->new(
        name => 'un_position',
        option => '=s',
        allow => ['top', 'bottom'],
        default => 'bottom',
        helptext => "Position of the 'user_note' in the smoke report.",
    );
}

1;
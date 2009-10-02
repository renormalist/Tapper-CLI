package Artemis::CLI::Testrun::Command::listqueue;

use 5.010;

use strict;
use warnings;

use parent 'App::Cmd::Command';

use Data::Dumper;
use Artemis::Model 'model';
use Artemis::Schema::TestrunDB;

sub abstract {
        'List queues'
}

my $options = { "verbose"  => { text => "show all available information; without only show names", short => 'v' },
                "minprio"  => { text => "INT; queues with at least this priority level", type => 'string'},
                "maxprio"  => { text => "INT; queues with at most this priority level", type => 'string'},
              };
                


sub opt_spec {
        my @opt_spec;
        foreach my $key (keys %$options) {
                my $pushkey = $key;
                $pushkey    = $pushkey."|".$options->{$key}->{short} if $options->{$key}->{short};

                given($options->{$key}->{type}){
                        when ("string")        {$pushkey .="=s";}
                        when ("withno")        {$pushkey .="!";}
                        when ("manystring")    {$pushkey .="=s@";}
                        when ("optmanystring") {$pushkey .=":s@";}
                        when ("keyvalue")      {$pushkey .="=s%";}
                }
                push @opt_spec, [$pushkey, $options->{$key}->{text}];
        }
        return (
                @opt_spec
               );
}


sub usage_desc {
        my $allowed_opts = join ' | ', map { '--'.$_ } _allowed_opts();
        "artemis-testruns listqueue " . $allowed_opts ;
}

sub _allowed_opts {
        my @allowed_opts = map { $_->[0] } opt_spec();
}

sub _extract_bare_option_names {
        map { s/=.*//; $_} _allowed_opts();
}

sub validate_args {
        my ($self, $opt, $args) = @_;

        
        my $msg = "Unknown option";
        $msg   .= ($args and $#{$args} >=1) ? 's' : '';
        $msg   .= ": ";
        if (($args and @$args)) {
                say STDERR $msg, join(', ',@$args);
                die $self->usage->text;
        }
        return 1;
}

sub run {
        my ($self, $opt, $args) = @_;
        my %options= (order_by => 'name');
        my %search;
        if ($opt->{minprio} and $opt->{maxprio}) {
                $search{"-and"} = { priority => {'>=' => $opt->{minprio}, priority => {'<=' => $opt->{maxprio}}}};
        } else {
                $search{priority} = {'>=' => $opt->{minprio}} if $opt->{minprio};
                $search{priority} = {'<=' => $opt->{maxprio}} if $opt->{maxprio};
        }
        my $queues = model('TestrunDB')->resultset('Queue')->search(\%search, \%options);
        if ($opt->{verbose}) {
                $self->print_queues_verbose($queues)
        } else {
                foreach my $queue ($queues->all) {
                        say sprintf("%10d | %s", $queue->id, $queue->name);
                }
        }
}


sub print_queues_verbose
{
        my ($self, $queues) = @_;
        my %max = (
                   host => 0,
                   queue => 0,
                  );
 QUEUE:
        foreach my $queue ($queues->all) {
                $max{queue} = length($queue->name) if length($queue->name) > $max{queue};
                next QUEUE if not $queue->queuehosts->count;
                foreach my $queuehost ($queue->queuehosts->all) {
                        $max{host} = length($queuehost->host->name) if length($queuehost->host->name) > $max{host};
                }
        }

        foreach my $queue ($queues->all) {
                my ($host_length, $queue_length) = ($max{host}, $max{queue});
                my $output = sprintf("%10d | %${queue_length}s | %5d",
                                     $queue->id, 
                                     $queue->name, 
                                     $queue->priority);
                if ($queue->queuehosts->count) {
                        foreach my $queuehost ($queue->queuehosts->all) {
                                $output.= sprintf(" | %${host_length}s",$queuehost->host->name);
                        }
                } 
                say $output;
        }
}


1;

# perl -Ilib bin/artemis-testrun list --id 16

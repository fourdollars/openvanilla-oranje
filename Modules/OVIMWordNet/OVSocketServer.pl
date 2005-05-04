#!/usr/bin/Perl -w -Tw
use strict;
use IO::Socket;
use Net::hostent;
use Encode;
use utf8;
use Lingua::Wordnet;

# 20310 = 0x4f56 = 'OV'
my $client;
my $server = IO::Socket::INET->new (Proto=>'tcp', LocalPort=>20310, Listen=>SOMAXCONN, Reuse=>1);

print "init wordnet...\n";
my $wn = new Lingua::Wordnet;
print "done!\n";

die "cannot setup server" unless $server;

# print STDERR "loading cj.cin.data\n";
# open (CJ, "<:utf8", "cj.cin.data");
# while (<CJ>) {
#    my @d=split;
#    # print "$d[0] => $d[1]\n";
#    $cjdata{$d[0]}.=encode("utf8", $d[1]);
# }
# close CJ;
# print STDERR "cj.cin.data loaded\n";

while ($client = $server->accept()) {
	print STDERR "OVSocketServer: Connected!\n";
	$client->autoflush(1);
	
	while(<$client>) {
        chomp;
        print STDERR "OVIMSocketServer: from client=$_\n";
        my @cmd=split (/\s/, decode("utf8", $_));        
        
        my $mod=shift @cmd;
        if ($mod =~ /ping/) {
            print $client "pong\n";
        }
        elsif  ($mod =~ /OVOFPerlTest/) {
            OVOFPerlTest(@cmd);
        } 
        elsif ($mod =~ /OVIMPerlTest/) {
            OVIMPerlTest(@cmd);
        }
	}

	close $client;
}	

print "OVSocketServer: Server closed\n";
close $server;


sub OVOFPerlTest {
    my $data=shift;
    my $src=shift;
    $src="" if (!defined $src);
    print STDERR "data=$data, src=$src\n";
    $src =~ s/吃/喫/g;
    $src =~ s/才/纔/g;
    $src =~ s/只/祇/g;
    print $client $data+1, " \"", encode("utf8", uc $src), "\"\n";
}

sub OVIMPerlTest {
    my $raw=shift;
    print STDERR "raw data=$raw\n";
    my @dataarr = ($raw =~ /\"(.*)\"/);
    my $data=$dataarr[0];
    my $code=shift;
    my $bufempty=shift;
    my $onscreen=shift;
    
    $data =~ s/\\\"/\"/g;

    print STDERR "data=$data, code=$code, bufempty=$bufempty, onscreen=$onscreen\n";
    
    my $c=chr $code;
    if ($code==32) {
        if (!length($data)) {
            print $client "\"$data\" keyreject\n";
        }
        else {
            my @synsetList;
            my $nounSynset = $wn->lookup_synset($data, "n", 1);
            if(defined $nounSynset) {
                push @synsetList, $nounSynset;
            }
            my $verbSynset = $wn->lookup_synset($data, "v", 1);
            if(defined $verbSynset) {
                push @synsetList, $verbSynset;
            }
            my $adjSynset = $wn->lookup_synset($data, "a", 1);
            if(defined $adjSynset) {
                push @synsetList, $adjSynset;
            }
            my $sSynset = $wn->lookup_synset($data, "s", 1);
            if(defined $sSynset) {
                push @synsetList, $sSynset;
            }
            my $rSynset = $wn->lookup_synset($data, "r", 1);
            if(defined $rSynset) {
                push @synsetList, $rSynset;
            }
            foreach my $synset (@synsetList) {
                my @synonyms = $synset->synonyms();            
                my $head = $synonyms[0];
                $head =~ s/\%\d+$//;
                my $words;
                if(defined $head) {
                    foreach my $word (@synonyms) {
                        $word =~ s/\%\d+$//;
                        $words .= $word . " ";
                    }
                    $data="";
                    print $client "\"$data\" bufclear bufappend \"$head\" bufsend candiclear candiappend \"$words\" candiupdate candishow srvnotify \"$head\" keyaccept\n";
                }
                else {
                    print $client "\"$data\" srvnotify \"no match!\" keyaccept\n";
                }                
            }
        }
    }
    elsif ($c =~ /[[:print:]]/) {
        $data .= $c;
        print $client "\"$data\" bufappend \"$c\" bufupdate candiappend \"$c\" candiupdate candishow keyaccept\n";
    }
    elsif ($code==13) {
        if (length $data) {
            print $client "\"\" candiclear candihide bufsend keyaccept\n";
        }
        else {
            print $client "\"$data\" keyreject\n";
        }
    } 
    elsif ($code==8) {
        if (length $data) {
            $data=substr($data, 0, -1);
            if (length $data) {
                print $client "\"$data\" bufclear bufappend \"$data\" bufupdate candiclear candiappend \"$data\" candiupdate keyaccept\n";
            }
            else {
                print $client "\"$data\" bufclear bufupdate candiclear candiupdate candihide keyaccept\n";
            }
        }
        else {
            print $client "\"$data\" keyreject\n";
        }
    }
    else {
        print $client "\"$data\" keyreject\n";
    }
}
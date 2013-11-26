package BackupPC::CGI::ActionStop;
 
use strict;
use BackupPC::CGI::Lib qw(:all);
 
sub action
{
 
 
my @hostsBack;
 
foreach my $key (keys %In) {
    push(@hostsBack,$In{$key}) if $key =~ /^doStop_[\w\._-]+$/;
}
 
ServerConnect();
 
my $reply;
 
foreach my $host (@hostsBack){
 
    if ($host =~ /^([\w\._-]+)$/) {
        $host = $1; #data is now untainted
    }
    my $Privileged = CheckPermission($host);
 
    if ( !$Privileged ) {
        ErrorExit("Only_privileged_users_can_stop");
    }
 
    $reply .= "Stop $host ".$bpc->ServerMesg("stop ${EscURI($host)} backuppc 0")."<br />";
 
}
 
    my $content = eval ("qq{$Lang->{REPLY_FROM_SERVER}}")."$reply";
    Header("ActionStop",$content);
 
    Trailer();  
 
}
 
1;

package BackupPC::CGI::LaunchMassBack;
 
use strict;
use BackupPC::CGI::Lib qw(:all);
 
 
sub action
{
 
my @hostsBack;
my $force = 0;
foreach my $key (keys %In) {
    push(@hostsBack,$In{$key}) if $key =~ /^doBack_[\w\._-]+$/;
    $force = 1 if $key =~ /^ForceBack$/;
}
 
 
my $back_type = defined($In{'Full'}) ? 1 : 0;
#(1 = full)
 
if ($force eq 1){
    my $FileForce = '/etc/backuppc/ForceBackup.pl';
 
    #on lis le fichier qui contient les noms des hosts backups à forcer
    my %ForceListe;
    open(FILEFORCE, "$FileForce");
        my @ForceListeRead = <FILEFORCE>;
    close(FILEFORCE);
    my $ForceListeRead=join " ", @ForceListeRead;
    #attribut les valeurs à la variable de hash
 
    if ($ForceListeRead =~ /^([^;]*;)$/) {                                                                                                                                                                     
        eval($1);
    }
    #ajout du nouvel host
 
    foreach my $host (@hostsBack){
        $ForceListe{$host} = 1;
    }
 
    #met en forme la syntaxe pour exporter dans le fichier
    my($ForceListeWrite) = Data::Dumper->new(
                     [  \%ForceListe],
                     [qw(*ForceListe)]);
    $ForceListeWrite->Indent(1);                                                                                                                                                                                
 
    #ecrit le fichier
    open (FILEFORCE, ">$FileForce");
        print(FILEFORCE $ForceListeWrite->Dump);
    close(FILEFORCE);
 
}
 
ServerConnect();
 
my $reply;
 
foreach my $host (@hostsBack){
 
    if ($host =~ /^([\w\._-]+)$/) {
        $host = $1; #data is now untainted
    }
    my $Privileged = CheckPermission($host);
 
    if ( !$Privileged ) {
        ErrorExit(eval("qq{$Lang->{Only_privileged_users_can_stop_or_start_backups}}"));
    }
 
    if ( $Hosts->{$host}{dhcp} ) {
        my $ipAddr     = ConfirmIPAddress($host);
        $reply .= eval("qq{$Lang->{Backup_requested_on_DHCP__host}}");
        $reply .= " -> ".$bpc->ServerMesg("backup $ipAddr ${EscURI($host)}"
                    . " $User $back_type")."<br />";
    } else {
        $reply .= eval("qq{$Lang->{Backup_requested_on__host_by__User}}");
        $reply .= " -> ".$bpc->ServerMesg("backup ${EscURI($host)}"
                    . " ${EscURI($host)} $User $back_type")."<br />";
    }
 
}
 
    my $content = eval ("qq{$Lang->{REPLY_FROM_SERVER}}")."$reply";
    Header("MassBackup",$content);
 
    Trailer();  
 
}
 
1;

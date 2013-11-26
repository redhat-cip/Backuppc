package BackupPC::CGI::Downtime;

use strict;
use BackupPC::CGI::Lib qw(:all);

my $Downhours = 23;
my $DowntimeList = '/tmp/check_backup_downtime';

sub action{

  ServerConnect();
  #Downtime by default
  #my $manage_downtime='/opt/enovance/nagios/client-scripts/check_backuppc_downtime.pl';
  my $strHeadAction = <<EOF;
<br>

EOF


  #my $vzlist='';
  my @vzlist;

  my @hostsDowntime;
  foreach my $key (keys %In) {
    if ($key =~ /^downtime_[\w\._-]+$/){
        print FILE $In{$key}."\n";
        $strHeadAction .= 'Downtime '.$In{$key}." for $Downhours hours<br />";
        #$vzlist .= "$In{$key} ";
        push (@vzlist,$In{$key});
    }
  }

  action_add(@vzlist);
  #system("$manage_downtime -a 20 -vz $vzlist") == 0 or die "couldn't execute $manage_downtime -a 20 -vz $vzlist: $!";

    my $content  =     $strHeadAction;
    Header("Downtime", $content);
    Trailer();

}

#Fonction venant de check_backuppc_downtime.pl
sub action_add {

    eval "use DateTime::Format::Strptime; 1" or die "Le module DateTime::Format::Strptime; doit être présent \"apt-get install libdatetime-format-strptime-perl\"";
    use POSIX qw(strftime);
    my $currentDate=strftime "%Y-%m-%d-%H%M%S", (localtime(time+($Downhours*3600)));
    my %hash_vz = map { $_ => $currentDate } @_;
    
    #verifie si le fichier existe
    if (-e $DowntimeList){
        open(TASK, "$DowntimeList") or die "Could not open file $DowntimeList $!";
            while (my $line = <TASK> ) { 
                $hash_vz{$1}=$2 if ($line =~ /^([^=]+)=([^\n]+)$/ && !$hash_vz{$1});
            }   
        close(TASK);
    }

    open(TASK,"> $DowntimeList") or die "Could write open file $DowntimeList $!";
        #ajouter tout les noms dans le fichiers hosts
        foreach my $key (keys %hash_vz) {
            print TASK "$key=$hash_vz{$key}\n";
        }
    close(TASK);
}

1;

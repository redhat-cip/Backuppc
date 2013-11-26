package BackupPC::CGI::ActionSummary;
 
use strict;
use BackupPC::CGI::Lib qw(:all);
 
sub action
{
    my($strBg, $strUser, $strCmd);
 
    GetStatusInfo("queues jobs");
    my $Privileged = CheckPermission();
 
    if ( !$Privileged ) {
        ErrorExit($Lang->{Only_privileged_users_can_view_queues_});
    }
 
 
    while ( @BgQueue ) {
        my $req = pop(@BgQueue);
        my($reqTime) = timeStamp2($req->{reqTime});
        $strBg .= <<EOF;
        <tr>
            <td> BgQueue </td>
            <td> ${HostLink($req->{host})} </td>
            <td> $req->{backupType} </td>
            <td>$reqTime </td>
            <td> backupType $req->{backupType}</td>
            <td align="center" class="border"><input type="checkbox" name="doStop_$req->{host}" value="$req->{host}"></td>
        </tr>
EOF
    }
 
    while ( @UserQueue ) {
        my $req = pop(@UserQueue);
        my $reqTime = timeStamp2($req->{reqTime});
        $strUser .= <<EOF;
        <tr>
            <td> UserQueue </td>
            <td> ${HostLink($req->{host})} </td>
            <td> $req->{backupType} </td>
            <td>$reqTime </td>
            <td> Backup $req->{backupType} </td>
            <td align="center" class="border"><input type="checkbox" name="doStop_$req->{host}" value="$req->{host}"></td>
        </tr>
EOF
    }
 
    while ( @CmdQueue ) {
        my $req = pop(@CmdQueue);
        my $reqTime = timeStamp2($req->{reqTime});
        (my $cmd = $bpc->execCmd2ShellCmd(@{$req->{cmd}})) =~ s/$BinDir\///;
        $strCmd .= <<EOF;
        <tr>
            <td> CmdQueue </td>
            <td> ${HostLink($req->{host})} </td>
            <td> Type </td>
            <td align="center">$reqTime </td>
            <td> $cmd </td>
            <td align="center" class="border"><input type="checkbox" name="doStop_$req->{host}" value="$req->{host}"></td>
        </tr>
EOF
    }
 
#Ajout traveaux en cours
 
    my $jobStr2;
    foreach my $host ( sort(keys(%Jobs)) ) {
        my $startTime = timeStamp2($Jobs{$host}{startTime});
        next if ( $host eq $bpc->trashJob
                    && $Jobs{$host}{processState} ne "running" );
        next if ( !$Privileged && !CheckPermission($host) );
        $Jobs{$host}{type} = $Status{$host}{type}
                    if ( $Jobs{$host}{type} eq "" && defined($Status{$host}));
        (my $cmd = $Jobs{$host}{cmd}) =~ s/$BinDir\///g;
        (my $xferPid = $Jobs{$host}{xferPid}) =~ s/,/, /g;
        $jobStr2 .= <<EOF;
<tr>
    <td class="border">Travaux en cours</td>
    <td class="border"> ${HostLink($host)} </td>
    <td align="center" class="border"> $Jobs{$host}{type} </td>
    <td class="border"> $startTime </td>
    <td class="border"> $cmd </td>
    <td align="center" class="border"><input type="checkbox" name="doStop_$host" value="$host"></td>
EOF
    }
 
 
 
my $strHeadAction = <<EOF;
<br>
${h2("Travaux en cours d'execution")}
<p>
<form method="post" action="/BackupPC_Admin" name="StopActionForm">
<table class="tableStnd" border cellspacing="1" cellpadding="3">
<tr class="tableheader">
    <td> Action </td>
    <td> Hote </td>
    <td> Type </td>
    <td> Date de depart </td>
    <td> Commande </td>
    <td align="center"> Select </td>
</tr>
 
 
$jobStr2
$strBg
$strUser
$strCmd
</table>
 
<br />
 
<input type=\"hidden\" id=\"action\" name=\"action\" value=\"actionstop\">
<input type=\"submit\" name=\"StopA" onClick="return confirm('Voulez annuler les actions ?')" value=\"Annuler les actions\"">
</form>
 
 
EOF
 
my $content  =     $strHeadAction; 
    Header("ActionSummary", $content);
    Trailer();
}
 
1;

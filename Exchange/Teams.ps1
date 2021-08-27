Function GetTeams {
    $Teams = Get-UnifiedGroup -ResultSize Unlimited 
    return $Teams.count
}
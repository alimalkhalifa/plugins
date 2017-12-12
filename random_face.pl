#::: Author: Proxeeus, based on Trevius awesome plugin.
#::: Usage: plugin::RandomFace(Mob);
#::: Description: Chooses a random face for a mob. We're in a classic -> velious timeline only, so the only features that matter are
#::: the face, texture, and helm texture of the npc.

sub RandomFace {
	my $Mob = $_[0];

	if ($Mob)
	{
		$MobRace = $Mob->GetRace();
		$Texture = $Mob->GetTexture();
		$HelmTexture = $Mob->GetHelmTexture();
		
		if ($MobRace <= 12 || $MobRace == 128 || $MobRace == 130 || $MobRace == 330 || $MobRace == 522)
		{
			
			$Gender = $Mob->GetGender();
			
			$Face = 0xFF;
			$Face = plugin::RandomRange(0, 7);
			
			$Mob->SendIllusion($MobRace,$Gender,$Texture,$HelmTexture,$Face,0,0,0,0,0,0,0); # ,$size
		}
	}

}


return 1; # Plugins may or may not require this return line.

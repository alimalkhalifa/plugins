#::: Author: Trevius
#::: Usage: plugin::RandomFeatures(Mob);
#::: Description: Chooses a random set of facial features for playable races (NPCs or Players)

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

#::: Author: Trevius
#::: Usage: plugin::CloneAppearance(MobA, MobB, CloneName=false)
#::: Description: Clones the look of a target
#:::	 MobA is the target mob to clone from
#:::	 MonB is the mob that is changing to clone MobA
#:::	 CloneName is an optional field that if set to 1 will clone the name of the target as well
sub CloneAppearance {
	my $MobA = $_[0];
	my $MobB = $_[1];
	my $CloneName = $_[2];
	
	my $Race = $MobA->GetRace();
	my $Gender = $MobA->GetGender();
	my $Texture = $MobA->GetTexture();
	my $HelmTexture = $MobA->GetHelmTexture();
	my $Face = $MobA->GetLuclinFace();
	my $HairStyle = $MobA->GetHairStyle();
	my $HairColor = $MobA->GetHairColor();
	my $Beard = $MobA->GetBeard();
	my $BeardColor = $MobA->GetBeardColor();
	my $DrakkinHeritage = $MobA->GetDrakkinHeritage();
	my $DrakkinTattoo = $MobA->GetDrakkinTattoo();
	my $DrakkinDetails = $MobA->GetDrakkinDetails();
	my $Size = $MobA->GetSize();
	
	if (!$Size)
	{
		%RaceSizes = (
			1 => 6, # Human
			2 => 8, # Barbarian
			3 => 6, # Erudite
			4 => 5, # Wood Elf
			5 => 5, # High Elf
			6 => 5, # Dark Elf
			7 => 5, # Half Elf
			8 => 4, # Dwarf
			9 => 9, # Troll
			10 => 9, # Ogre
			11 => 3, # Halfling
			12 => 3, # Gnome
			128 => 6, # Iksar
			130 => 6, # Vah Shir
			330 => 5, # Froglok
			522 => 6, # Drakkin
		);
		
		$Size = $RaceSizes{$Race};
	}
	
	if (!$Size)
	{
		$Size = 6;
	}

	if ($Size > 15)
	{
		$Size = 15;
	}
	
	$MobB->SendIllusion($Race, $Gender, $Texture, $HelmTexture, $Face, $HairStyle, $HairColor, $Beard, $BeardColor, $DrakkinHeritage, $DrakkinTattoo, $DrakkinDetails, $Size);
	
	for ($slot = 0; $slot < 7; $slot++)
	{
		my $Color = 0;
		my $Material = 0;
		if ($MobA->IsClient() || $slot > 6)
		{
			$Color = $MobA->GetEquipmentColor($slot);
			$Material = $MobA->GetEquipmentMaterial($slot);
		}
		else
		{
			$Color = $MobA->GetArmorTint($slot);
			if ($slot == 0)
			{
				$Material = $MobA->GetHelmTexture();
			}
			else
			{
				$Material = $MobA->GetTexture();
			}
		}
		$MobB->WearChange($slot, $Material, $Color);
	}
	
	$PrimaryModel = $MobA->GetEquipmentMaterial(7);
	$SecondaryModel = $MobA->GetEquipmentMaterial(8);
	
	# NPCs can set animations and attack messages, but clients only set the model change
	if ($MobB->IsNPC())
	{
		plugin::SetWeapons($PrimaryModel, $SecondaryModel, 1);
	}
	else
	{
		$MobB->WearChange(7, $PrimaryModel, 0);
		$MobB->WearChange(8, $SecondaryModel, 0);
	}
	
	if ($CloneName)
	{
		my $CloneName = $MobA->GetCleanName();
		$MobB->TempName($CloneName);
	}
	
	
}

return 1; # Plugins may or may not require this return line.
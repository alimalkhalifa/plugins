sub Spawn2 {
    my $npcid = shift;
    my $amount = shift;
    my $x = shift;
    my $y = shift;
    my $z = shift;
    for ($i = 0; $i < $amount; $i++) {
        quest::spawn2($npcid, 0, 0, ($x + quest::ChooseRandom(-15..15)), ($y + quest::ChooseRandom(-15..15)), $z, 0);
    }
}

#[12:25 AM] Kinglykrab: Spawn set amount of an NPC at a specified XYZ with some random X/Y.

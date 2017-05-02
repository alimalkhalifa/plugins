# plugin::check_handin($item1 => #required_amount,...);
# autoreturns extra unused items on success
sub check_handin {
    my $hashref = shift;
    my %required = @_;
    foreach my $req (keys %required) {
	if ((!defined $hashref->{$req}) || ($hashref->{$req} != $required{$req})) {
            return(0);
	}
    }
     foreach my $req (keys %required) {
         if ($required{$req} < $hashref->{$req}) {
             $hashref->{$req} -= $required{$req};
         } else {
             delete $hashref->{$req};
         }
     }
     return 1;
}

sub stop_return { 
	use Time::HiRes qw(time); 
	my $client = plugin::val('$client');
	$client->SetEntityVariable("Stop_Return", time());
}

sub return_items {    
	my $hashref = plugin::var('$itemcount');
	my $client = plugin::val('$client');
	my $name = plugin::val('$name');
	my $status = plugin::val('$status');
	my $items_returned = 0;

	my %ItemHash = (
		0 => [ plugin::val('$item1'), plugin::val('$item1_charges'), plugin::val('$item1_attuned') ],
		1 => [ plugin::val('$item2'), plugin::val('$item2_charges'), plugin::val('$item2_attuned') ],
		2 => [ plugin::val('$item3'), plugin::val('$item3_charges'), plugin::val('$item3_attuned') ],
		3 => [ plugin::val('$item4'), plugin::val('$item4_charges'), plugin::val('$item4_attuned') ],
	);
	
	#::: Example output from $_[0] or what is known as hash %itemcount
	#::: $VAR1 = \{
	#::: 	'99048' => 1,
	#::: 	'190100' => 2,
	#::: 	'112801' => 1
	#::: }; 

	use Time::HiRes qw(time);
	use POSIX qw(strftime);

	my $t = time;
	my $date = strftime "%Y%m%d %H:%M:%S", localtime $t;
	$date .= sprintf ".%03d", ($t-int($t))*1000; # without rounding

	print $date, "\n";
	$client->Message(15, "Time is " . localtime() . " time " . time());

	if($client->GetEntityVariable("Stop_Return") > (time() - .3)){
		if($debug == 1){
			$client->Message(15, "Recieved quest signal to stop item return");
			$client->Message(15, "Recieved item time is  " . $client->GetEntityVariable("Stop_Return") . " difference is  " . ($client->GetEntityVariable("Stop_Return") - time()));
			$client->Message(15, "Stop Return is  " . $client->GetEntityVariable("Stop_Return") . " Current is  " . ((time() - .3)) . " diff_cur is " . ($client->GetEntityVariable("Stop_Return") - (time() - .3)));
		}
		return; 
	}
	elsif($client->GetEntityVariable("Recieved_Item") > (time() - .3)){ 
		if($debug == 1){
			$client->Message(15, "Recieved item time is  " . $client->GetEntityVariable("Recieved_Item") . " difference is  " . ($client->GetEntityVariable("Recieved_Item") - time()));
			$client->Message(15, "Client recieved item, do not hand anything back and return");
		}
		return; 
	}
	elsif($client->GetEntityVariable("DoubleProcessCheck") > (time() - .3)){
		if($debug == 1){
			$client->Message(15, " --- This is a double process");
			$client->Message(15, " --- Windowed Time " . (time() - $client->GetEntityVariable("DoubleProcessCheck")));
			$client->Message(15, " --- Stored Time " . $client->GetEntityVariable("DoubleProcessCheck")); 
			$client->Message(15, " --- Window Actual Time " . (time() - 1));
			$client->SetEntityVariable("DoubleProcessCheck", -10000); 
		}
		return;
	}
	else{
		#$client->Message(15, "Setting window time");
		$client->SetEntityVariable("DoubleProcessCheck", time());
	}

	foreach my $k (keys(%{$hashref}))
	{
		next if($k == 0);
		my $rcount = $hashref->{$k};
		my $r;
		for ($r = 0; $r < 4; $r++)
		{
			if ($rcount > 0 && $ItemHash{$r}[0] && $ItemHash{$r}[0] == $k)
			{
				if ($client)
				{
					$client->SummonItem($k, $ItemHash{$r}[1], $ItemHash{$r}[2]);
					quest::say("I have no need for this $name, you can have it back.");
					quest::doanim(64);
					$items_returned = 1;
				}
				else
				{
					# This shouldn't be needed, but just in case
					quest::summonitem($k, 0);
					$items_returned = 1;
				}
				$rcount--;
			}
		}
		delete $hashref->{$k};
	}
	# Return true if items were returned
	return $items_returned;

}

sub mq_process_items {
	my $hashref = shift;
	my $npc = plugin::val('$npc');
	my $trade = undef;
	
	if($npc->EntityVariableExists("_mq_trade")) {
		$trade = decode_eqemu_item_hash($npc->GetEntityVariable("_mq_trade")); 
	} else {
		$trade = {};
	}
	
	foreach my $k (keys(%{$hashref})) {
		next if($k == 0);
		
		if(defined $trade->{$k}) {
			$trade->{$k} = $trade->{$k} + $hashref->{$k};
		} else {
			$trade->{$k} = $hashref->{$k};
		}
	}
	
	my $str = encode_eqemu_item_hash($trade);
	$npc->SetEntityVariable("_mq_trade", $str);
}

sub check_mq_handin {
	my %required = @_;
	my $npc = plugin::val('$npc');
	my $trade = undef;
	
	if($npc->EntityVariableExists("_mq_trade")) {
		$trade = decode_eqemu_item_hash($npc->GetEntityVariable("_mq_trade"));
	} else {
		return 0;
	}
	
	foreach my $req (keys %required) {
		if((!defined $trade->{$req}) || ($trade->{$req} < $required{$req})) {
				return 0;
		}
	}
	
	foreach my $req (keys %required) {
		if ($required{$req} < $trade->{$req}) {
			$trade->{$req} -= $required{$req};
		} else {
			delete $trade->{$req};
		}
	}
	
	$npc->SetEntityVariable("_mq_trade", encode_eqemu_item_hash($trade));
	return 1;
}

sub clear_mq_handin {
	my $npc = plugin::val('$npc');
	$npc->SetEntityVariable("_mq_trade", "");
}

sub encode_eqemu_item_hash {
	my $hashref = shift;
	my $str = "";
	my $i = 0;
	
	foreach my $k (keys(%{$hashref})) {
		if($i != 0) {
			$str .= ",";
		} else {
			$i = 1;
		}
		
		$str .= $k;
		$str .= "=";
		$str .= $hashref->{$k};
	}
	
	return $str;
}

sub decode_eqemu_item_hash {
	my $str = shift;
	my $hashref = { };
	
	my @vals = split(/,/, $str);
	my $val_len = @vals;
	for(my $i = 0; $i < $val_len; $i++) {
		my @subval = split(/=/, $vals[$i]);
		my $subval_len = @subval;
		if($subval_len == 2) {
			my $key = $subval[0];
			my $value = $subval[1];
			
			$hashref->{$key} = $value;
		}
	}
	
	return $hashref;
}

class X2Effect_AdjustOWPenalty extends X2Effect_Persistent;

var float NewReactionFirePenalty;

function ModifyReactionFireSuccess(XComGameState_Unit UnitState, XComGameState_Unit TargetState, out int Modifier)
{
	local float		StandardAim;
	local float		ReactionFireAim;
	local float 	ModifiedReactionFireAim;	
		
	StandardAim = UnitState.GetCurrentStat(eStat_Offense);						
	ReactionFireAim = ((1.0f-class'X2AbilityToHitCalc_StandardAim'.default.REACTION_FINALMOD) * StandardAim);

	ModifiedReactionFireAim = StandardAim * NewReactionFirePenalty;

	Modifier = Round(StandardAim - ReactionFireAim - (StandardAim-ModifiedReactionFireAim));

}


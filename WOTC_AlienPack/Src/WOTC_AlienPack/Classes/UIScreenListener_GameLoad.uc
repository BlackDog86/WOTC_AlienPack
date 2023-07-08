//---------------------------------------------------------------------------------------
//  FILE:    UIScreenListener_GameLoad
//  AUTHOR:  Amineri / Long War Studios
//
//  PURPOSE: Implements hooks to execute things when a new save is loaded or a campaign entered
//			This implementation "polls" more often that is desired, since we don't have a good way to detect when a new save has been loade
//---------------------------------------------------------------------------------------

class UIScreenListener_GameLoad extends UIScreenListener;

defaultproperties
{
	// Leave this none so it can be triggered anywhere, gate inside the OnInit
	ScreenClass = UITacticalHUD;
}

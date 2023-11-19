class X2StrategyElement_NewTechs_BD extends X2StrategyElement config(GameData);

var config int MIN_DISASSEMBLY_INTEL;
var config int VARIABLE_DISASSEMBLY_INTEL;

//var config int MIN_DISASSEMBLY_SUPPLIES;
//var config int VARIABLE_SUPPLIES_AMOUNT;


static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Techs;

	Techs.AddItem(CreateAutopsyMutonEliteBDTemplate());
	Techs.AddItem(DisAssembleDrones());
	return Techs;
}

static function X2DataTemplate CreateAutopsyMutonEliteBDTemplate()
{
	local X2TechTemplate Template;
	local ArtifactCost Artifacts;

	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'AutopsyMutonElite');
	Template.bAutopsy = true;
	Template.PointsToComplete = 4200;
	Template.SortingTier = 2;
	Template.bCheckForceInstant = true;

	Template.TechStartedNarrative = "LWNarrativeMoments_Bink.Autopsy_MutonM3_LW";

	Template.strImage = "img:///LWMutonEliteAutopsy.IC_AutopsyMutonElite"; 

	Template.Requirements.RequiredTechs.AddItem('AutopsyMuton');
	Template.Requirements.RequiredItems.AddItem('CorpseMutonElite');
	
	// Instant Requirements. Will become the Cost if the tech is forced to Instant.
	Artifacts.ItemTemplateName = 'CorpseMutonElite';
	Artifacts.Quantity = 10;
	Template.InstantRequirements.RequiredItemQuantities.AddItem(Artifacts);

	// Cost
	Artifacts.ItemTemplateName = 'CorpseMutonElite';
	Artifacts.Quantity = 1;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);

	return Template;
}

static function X2DataTemplate DisAssembleDrones()
{
	local X2TechTemplate Template;
	local ArtifactCost Artifacts;
	
	`CREATE_X2TEMPLATE(class'X2TechTemplate', Template, 'DisassembleDrones_BD');
	Template.PointsToComplete = 480;
	Template.SortingTier = 1;
	Template.strImage = "img:///UILibrary_BD_LWAlienPack.LW_Corpse_Drone";
	//Template.bProvingGround = true;
	Template.bRepeatable = true;
	Template.ResearchCompletedFn = DisAssembleDroneTechCompleted;
	
	Template.Requirements.RequiredTechs.AddItem('AutopsyAdventMEC');
	Template.Requirements.RequiredItems.AddItem('CorpseDrone');

	// Cost
	Artifacts.ItemTemplateName = 'CorpseDrone';
	Artifacts.Quantity = 3;
	Template.Cost.ArtifactCosts.AddItem(Artifacts);
		
	return Template;
}

static function DisAssembleDroneTechCompleted(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local XComGameStateHistory History;
	local XComGameState_HeadquartersXCom XComHQ;
	local int IntelAmount, TechID;

	History = `XCOMHISTORY;

	foreach NewGameState.IterateByClassType(class'XComGameState_HeadquartersXCom', XComHQ)
	{
		break;
	}

	if(XComHQ == none)
	{
		XComHQ = XComGameState_HeadquartersXCom(History.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersXCom'));
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', XComHQ.ObjectID));
	}
	
	if(XComHQ == none)
	{
	`log("Still no XCOMHQ found, why?");
	}

	IntelAmount = Max(1,`SYNC_RAND_STATIC(default.VARIABLE_DISASSEMBLY_INTEL) + default.MIN_DISASSEMBLY_INTEL);
	//SuppliesAmount = Max(1, `SYNC_RAND_STATIC(default.VARIABLE_SUPPLIES_AMOUNT) + default.MIN_DISASSEMBLY_SUPPLIES);
	
	TechID = TechState.ObjectID;
	TechState = XComGameState_Tech(NewGameState.GetGameStateForObjectID(TechID));

	if(TechState == none)
	{
		`log("No tech state?");
		TechState = XComGameState_Tech(NewGameState.ModifyStateObject(class'XComGameState_Tech', TechID));
	}

	TechState.IntelReward = IntelAmount;
	XComHQ.AddResource(NewGameState, 'Intel', IntelAmount);
	//XComHQ.AddResource(NewGameState, 'Supplies', SuppliesAmount);
}
//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_PPAlienAbilities
//  AUTHOR:  Amineri / John Lumpkin (Long War Studios)
//  PURPOSE: Defines alienpack ability templates copied from PerkPack
//---------------------------------------------------------------------------------------

class X2Ability_PPAlienAbilities extends X2Ability config(WOTC_AlienPack);

//Tactical Sense
//DepthPerception
//Infighter
//LightningReflexes_LW
//LightEmUp
//DamnGoodGround
//Executioner
//HitandRun
//LockedOn
//TraverseFire

var config int AREA_SUPPRESSION_AMMO_COST;
var config int AREA_SUPPRESSION_MAX_SHOTS;
var config int AREA_SUPPRESSION_SHOT_AMMO_COST;
var config float AREA_SUPPRESSION_RADIUS;
var config int WILLTOSURVIVE_WILLBONUS;
var config int DAMAGE_CONTROL_DURATION; 
var config int DAMAGE_CONTROL_BONUS_ARMOR;
var config int CCS_AMMO_PER_SHOT;
var config int AREA_SUPPRESSION_LW_SHOT_AIM_BONUS;
var config int DANGER_ZONE_BONUS_RADIUS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(AddDamnGoodGroundAbility());
	Templates.AddItem(AddDepthPerceptionAbility());
	Templates.AddItem(AddExecutionerAbility());
	Templates.AddItem(AddInfighterAbility());
	Templates.AddItem(AddLightEmUpAbility());
	Templates.AddItem(AddLightningReflexes_LWAbility());
	Templates.AddItem(AddLockedOnAbility());
	Templates.AddItem(AddTacticalSenseAbility());
	Templates.AddItem(AddTraverseFireAbility());
	TEmplates.AddItem(AddAreaSuppressionAbility());
	Templates.AddItem(AreaSuppressionShot_LW());
	Templates.AddItem(AddEvasiveAbility());
	Templates.AddItem(RemoveEvasive()); // Additional Ability	
	Templates.AddItem(AddLowProfileAbility());
	Templates.AddItem(AddHardTargetAbility());
	Templates.AddItem(AddCloseCombatSpecialistAbility());
	Templates.AddItem(CloseCombatSpecialistAttack()); //Additional Ability
	Templates.AddItem(AddCloseandPersonalAbility());
	Templates.AddItem(AddWilltoSurviveAbility()); 
	Templates.AddItem(AddAggressionAbility());
	Templates.AddItem(AddBringEmOnAbility());
	Templates.AddItem(AddDefiladeAbility());
	Templates.AddItem(DefiladePassive());
	Templates.AddItem(AddFireDisciplineAbility());
	Templates.AddItem(FireDisciplinePassive());
	Templates.AddItem(AddDamageControlAbility());
	Templates.AddItem(AddDamageControlAbilityPassive()); //Additional Ability
	Templates.AddItem(AddLoneWolfAbility());
	return Templates;
}

static function X2AbilityTemplate AddLoneWolfAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_LoneWolf					AimandDefModifiers;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_Lonewolf_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityLoneWolf";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	AimandDefModifiers = new class 'X2Effect_LoneWolf';
	AimandDefModifiers.BuildPersistentEffect (1, true, false);
	AimandDefModifiers.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (AimandDefModifiers);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;	
	//no visualization
	return Template;		
}

static function X2AbilityTemplate AddDamageControlAbilityPassive()
{
	local X2AbilityTemplate                 Template;	

	Template = PurePassive('BD_DamageControl_LWPassive', "img:///UILibrary_LWAlienPack.LW_AbilityDamageControl", true, 'eAbilitySource_Perk');
	Template.bCrossClassEligible = false;
	//Template.AdditionalAbilities.AddItem('DamageControlAbilityActivated');
	return Template;
}

static function X2AbilityTemplate AddDamageControlAbility()
{
	local X2AbilityTemplate						Template;	
	local X2AbilityTrigger_EventListener		EventListener;
	local X2Effect_DamageControl 				DamageControlEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_DamageControl_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityDamageControl";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	//Template.bIsPassive = true;
	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// Trigger on Damage
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'UnitTakeEffectDamage';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	DamageControlEffect = new class'X2Effect_DamageControl';
	DamageControlEffect.BuildPersistentEffect(default.DAMAGE_CONTROL_DURATION,false,true,,eGameRule_PlayerTurnBegin);
	DamageControlEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	DamageControlEffect.DuplicateResponse = eDupe_Refresh;
	DamageControlEffect.BonusArmor = default.DAMAGE_CONTROL_BONUS_ARMOR;
	Template.AddTargetEffect(DamageControlEffect);
	
	Template.AddTargetEffect(DamageControlEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	//Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.AdditionalAbilities.AddItem('BD_DamageControl_LWPassive');

	return Template;
}

//CAPT 1 Defilade adds x% bonus to cover
static function X2AbilityTemplate AddDefiladeAbility()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_Defilade					DefiladeEffect;
	local X2AbilityTrigger_EventListener 	EventListener;
	local X2Condition_UnitProperty			TargetProperty;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_Defilade_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LWOfficers_AbilityHitTheDirt"; 
	Template.AbilitySourceName = 'eAbilitySource_Perk'; 
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireSquadmates = true;
	TargetProperty.ExcludePanicked = true;
	TargetProperty.ExcludeRobotic = true;
	TargetProperty.ExcludeStunned = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'OnUnitBeginPlay';
	EventListener.ListenerData.EventFn = AuraOnUnitBeginPlay;
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_None;
	Template.AbilityTriggers.AddItem(EventListener);

	DefiladeEffect = new class'X2Effect_Defilade';
	DefiladeEffect.BuildPersistentEffect (1, true, false);
	DefiladeEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	Template.AddTargetEffect(DefiladeEffect);

	Template.AdditionalAbilities.AddItem('BD_Defilade_LWPassive');

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate DefiladePassive()
{
	return PurePassive('BD_Defilade_LWPassive', "img:///UILibrary_LWAlienPack.LWOfficers_AbilityHitTheDirt", , 'eAbilitySource_Perk');
}

//COL 1 Fire Discipline 
static function X2AbilityTemplate AddFireDisciplineAbility()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_FireDiscipline			FireDisciplineEffect;
	local X2AbilityTrigger_EventListener 	EventListener;
	local X2Condition_UnitProperty			TargetProperty;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_FireDiscipline_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LWOfficers_AbilityFireDiscipline"; 
	Template.AbilitySourceName = 'eAbilitySource_Perk'; 
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.DisplayTargetHitChance = false;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;
	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.ExcludeHostileToSource = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireSquadmates = true;
	TargetProperty.ExcludePanicked = true;
	TargetProperty.ExcludeRobotic = true;
	TargetProperty.ExcludeStunned = true;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'OnUnitBeginPlay';
	EventListener.ListenerData.EventFn = AuraOnUnitBeginPlay;
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_None;
	Template.AbilityTriggers.AddItem(EventListener);

	FireDisciplineEffect = new class'X2Effect_FireDiscipline';
	FireDisciplineEffect.BuildPersistentEffect (1, true, false);
	FireDisciplineEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName);
	Template.AddTargetEffect(FireDisciplineEffect);

	Template.AdditionalAbilities.AddItem('BD_BD_FireDiscipline_LW_LWPassive');

	Template.bSkipFireAction = true;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate FireDisciplinePassive()
{
	return PurePassive('BD_FireDiscipline_LWPassive', "img:///UILibrary_LWAlienPack.LWOfficers_AbilityFireDiscipline", , 'eAbilitySource_Perk');
}

static function EventListenerReturn AuraOnUnitBeginPlay(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	local XComGameState_Ability SourceAbilityState;

	SourceAbilityState = XComGameState_Ability(CallbackData);	
	UnitState = XComGameState_Unit(EventData);

	if (SourceAbilityState != None  && UnitState != none) {	
		SourceAbilityState.AbilityTriggerAgainstSingleTarget(UnitState.GetReference(), false);
	}

	return ELR_NoInterrupt;
}


static function X2AbilityTemplate AddBringEmOnAbility()
{
	local X2AbilityTemplate						Template;
	local X2Effect_BringEmOn		            DamageEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_BringEmOn_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityBringEmOn";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	DamageEffect = new class'X2Effect_BringEmOn';
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(DamageEffect);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  No visualization
	return Template;
}


static function X2AbilityTemplate AddAggressionAbility()
{
	local X2AbilityTemplate				Template;
	local X2Effect_Aggression			MyCritModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_Aggression_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityAggression";	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	MyCritModifier = new class 'X2Effect_Aggression';
	MyCritModifier.BuildPersistentEffect (1, true, false);
	MyCritModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (MyCritModifier);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;	
}

static function X2AbilityTemplate AddCloseandPersonalAbility()
{
	local X2AbilityTemplate						Template;
	local X2Effect_CloseandPersonal				CritModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_CloseandPersonal_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityCloseandPersonal";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	CritModifier = new class 'X2Effect_CloseandPersonal';
	CritModifier.BuildPersistentEffect (1, true, false);
	CritModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (CritModifier);
	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate AddWilltoSurviveAbility()
{
	local X2AbilityTemplate						Template;
	local X2Effect_WilltoSurvive				ArmorBonus;
	local X2Effect_PersistentStatChange			WillBonus;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_WilltoSurvive_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityWilltoSurvive";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	ArmorBonus = new class 'X2Effect_WilltoSurvive';
	ArmorBonus.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	ArmorBonus.BuildPersistentEffect(1, true, false);
	Template.AddTargetEffect(ArmorBonus);

	WillBonus = new class'X2Effect_PersistentStatChange';
	WillBonus.AddPersistentStatChange(eStat_Will, float(default.WILLTOSURVIVE_WILLBONUS));
	WillBonus.BuildPersistentEffect (1, true, false, false, eGameRule_PlayerTurnBegin);
	Template.AddTargetEffect(WillBonus);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.WillLabel, eStat_Will, default.WILLTOSURVIVE_WILLBONUS);

	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  No visualization
	return Template;
}

static function X2AbilityTemplate AddCloseCombatSpecialistAbility()
{
	local X2AbilityTemplate                 Template;

	Template = PurePassive('BD_CloseCombatSpecialist_LW', "img:///UILibrary_LWAlienPack.LW_AbilityCloseCombatSpecialist", false, 'eAbilitySource_Perk');
	Template.AdditionalAbilities.AddItem('BD_CloseCombatSpecialist_LWAttack');
	return Template;
}

static function X2AbilityTemplate CloseCombatSpecialistAttack()
{
	local X2AbilityTemplate								Template;
	local X2AbilityToHitCalc_StandardAim				ToHitCalc;
	local X2AbilityTrigger_Event						Trigger;
	local X2Effect_Persistent							CloseCombatSpecialistTargetEffect;
	local X2Condition_UnitEffectsWithAbilitySource		CloseCombatSpecialistTargetCondition;
	local X2AbilityTrigger_EventListener				EventListener;
	local X2Condition_UnitProperty						SourceNotConcealedCondition;
	local X2Condition_UnitEffects						SuppressedCondition;
	local X2Condition_Visibility						TargetVisibilityCondition;
	local X2AbilityCost_Ammo							AmmoCost;
	local X2AbilityTarget_Single_CCS					SingleTarget;
	//local X2AbilityCooldown							Cooldown;	

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_CloseCombatSpecialist_LWAttack');

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityCloseCombatSpecialist";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CAPTAIN_PRIORITY;
	Template.Hostility = eHostility_Defensive;
	Template.bCrossClassEligible = false;

	ToHitCalc = new class'X2AbilityToHitCalc_StandardAim';
	ToHitCalc.bReactionFire = true;
	Template.AbilityToHitCalc = ToHitCalc;
	 
	//Cooldown = new class'X2AbilityCooldown';
	//Cooldown.iNumTurns = 1;
    //Template.AbilityCooldown = Cooldown;

	AmmoCost = new class 'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = default.CCS_AMMO_PER_SHOT;
	Template.AbilityCosts.AddItem(AmmoCost);
	
	//  trigger on movement
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_MovementObserver';
	Trigger.MethodName = 'PostBuildGameState';
	Template.AbilityTriggers.AddItem(Trigger);
	//  trigger on an attack
	Trigger = new class'X2AbilityTrigger_Event';
	Trigger.EventObserverClass = class'X2TacticalGameRuleset_AttackObserver';
	Trigger.MethodName = 'InterruptGameState';
	Template.AbilityTriggers.AddItem(Trigger);

	//  it may be the case that enemy movement caused a concealment break, which made Bladestorm applicable - attempt to trigger afterwards
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitConcealmentBroken';
	EventListener.ListenerData.Filter = eFilter_Unit;
	EventListener.ListenerData.EventFn = CloseCombatSpecialistConcealmentListener;
	EventListener.ListenerData.Priority = 55;
	Template.AbilityTriggers.AddItem(EventListener);
	
	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitDisallowMindControlProperty);
	TargetVisibilityCondition = new class'X2Condition_Visibility';
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	TargetVisibilityCondition.bRequireBasicVisibility = true;
	TargetVisibilityCondition.bDisablePeeksOnMovement = true; //Don't use peek tiles for over watch shots	
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);
	Template.AbilityTargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	Template.AddShooterEffectExclusions();

	//Don't trigger when the source is concealed
	SourceNotConcealedCondition = new class'X2Condition_UnitProperty';
	SourceNotConcealedCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(SourceNotConcealedCondition);

	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	SingleTarget = new class 'X2AbilityTarget_Single_CCS';
	//SingleTarget.OnlyIncludeTargetsInsideWeaponRange = true;
	Template.AbilityTargetStyle = SingleTarget;

	Template.bAllowBonusWeaponEffects = true;
	Template.AddTargetEffect(class 'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	//Prevent repeatedly hammering on a unit when CCS triggers.
	//(This effect does nothing, but enables many-to-many marking of which CCS attacks have already occurred each turn.)
	CloseCombatSpecialistTargetEffect = new class'X2Effect_Persistent';
	CloseCombatSpecialistTargetEffect.BuildPersistentEffect(1, false, true, true, eGameRule_PlayerTurnEnd);
	CloseCombatSpecialistTargetEffect.EffectName = 'CloseCombatSpecialistTarget';
	CloseCombatSpecialistTargetEffect.bApplyOnMiss = true; //Only one chance, even if you miss (prevents crazy flailing counter-attack chains with a Muton, for example)
	Template.AddTargetEffect(CloseCombatSpecialistTargetEffect);
	
	CloseCombatSpecialistTargetCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	CloseCombatSpecialistTargetCondition.AddExcludeEffect('CloseCombatSpecialistTarget', 'AA_DuplicateEffectIgnored');
	Template.AbilityTargetConditions.AddItem(CloseCombatSpecialistTargetCondition);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;
}

//Must be static, because it will be called with a different object (an XComGameState_Ability)
//Used to trigger Bladestorm when the source's concealment is broken by a unit in melee range (the regular movement triggers get called too soon)
static function EventListenerReturn CloseCombatSpecialistConcealmentListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit ConcealmentBrokenUnit;
	local StateObjectReference CloseCombatSpecialistRef;
	local XComGameState_Ability CloseCombatSpecialistState;
	local XComGameStateHistory History;

	History = `XCOMHISTORY;

	ConcealmentBrokenUnit = XComGameState_Unit(EventSource);	
	if (ConcealmentBrokenUnit == None)
		return ELR_NoInterrupt;

	//Do not trigger if the CloseCombatSpecialist soldier himself moved to cause the concealment break - only when an enemy moved and caused it.
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext().GetFirstStateInEventChain().GetContext());
	if (AbilityContext != None && AbilityContext.InputContext.SourceObject != ConcealmentBrokenUnit.ConcealmentBrokenByUnitRef)
		return ELR_NoInterrupt;

	CloseCombatSpecialistRef = ConcealmentBrokenUnit.FindAbility('CloseCombatSpecialistAttack');
	if (CloseCombatSpecialistRef.ObjectID == 0)
		return ELR_NoInterrupt;

	CloseCombatSpecialistState = XComGameState_Ability(History.GetGameStateForObjectID(CloseCombatSpecialistRef.ObjectID));
	if (CloseCombatSpecialistState == None)
		return ELR_NoInterrupt;
	
	CloseCombatSpecialistState.AbilityTriggerAgainstSingleTarget(ConcealmentBrokenUnit.ConcealmentBrokenByUnitRef, false);
	return ELR_NoInterrupt;
}

static function X2AbilityTemplate AddHardTargetAbility()
{
	local X2AbilityTemplate						Template;
	local X2Effect_HardTarget					DodgeBonus;
		
	`CREATE_X2ABILITY_TEMPLATE (Template, 'HardTarget');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityHardTarget";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	DodgeBonus = new class 'X2Effect_HardTarget';
	DodgeBonus.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	DodgeBonus.BuildPersistentEffect(1, true, false);
	Template.AddTargetEffect(DodgeBonus);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  No visualization

	return Template;
}

static function X2AbilityTemplate AddLowProfileAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_LowProfile_LW			DefModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_LowProfile_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityLowProfile";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	DefModifier = new class 'X2Effect_LowProfile_LW';
	DefModifier.BuildPersistentEffect (1, true, false);
	DefModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (DefModifier);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;	
	//no visualization
	return Template;
}

static function X2AbilityTemplate AddEvasiveAbility()
{
	local X2AbilityTemplate						Template;	
	local X2Effect_PersistentStatChange			DodgeBonus;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_Evasive_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityEvasive";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;
	Template.bcrossclasseligible = false;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	DodgeBonus = new class'X2Effect_PersistentStatChange';
	DodgeBonus.BuildPersistentEffect(1,true,true,false);
	DodgeBonus.SetDisplayInfo (ePerkBuff_Passive,Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,,, Template.AbilitySourceName); 
	DodgeBonus.AddPersistentStatChange (eStat_Dodge, float (100));
	DodgeBonus.EffectName='EvasiveEffect';
	Template.AddTargetEffect(DodgeBonus);

	Template.AdditionalAbilities.AddItem('RemoveBD_Evasive_LW');
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;  

	Return Template;
}

static function X2AbilityTemplate RemoveEvasive()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTrigger_EventListener		EventListener;
	local X2Effect_RemoveEffects				RemoveEffect;
	local X2Condition_UnitEffects				RequireEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RemoveBD_Evasive_LW');	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityEvasive";
	Template.Hostility = eHostility_Neutral;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.AbilityToHitCalc = default.DeadEye;
    Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.EventID = 'UnitTakeEffectDamage';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	RequireEffect = new class'X2Condition_UnitEffects';
    RequireEffect.AddRequireEffect('EvasiveEffect', 'AA_EvasiveEffectPresent');
	Template.AbilityTargetConditions.AddItem(RequireEffect);

	RemoveEffect = new class'X2Effect_RemoveEffects';
	RemoveEffect.EffectNamesToRemove.AddItem('EvasiveEffect');
	Template.AddTargetEffect(RemoveEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	Return Template;
}

static function X2AbilityTemplate AddDamnGoodGroundAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_DamnGoodGround		AimandDefModifiers;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_DamnGoodGround_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityDamnGoodGround"; //TODO
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	AimandDefModifiers = new class 'X2Effect_DamnGoodGround';
	AimandDefModifiers.BuildPersistentEffect (1, true, true);
	AimandDefModifiers.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (AimandDefModifiers);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

static function X2AbilityTemplate AddExecutionerAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Executioner_AP			AimandCritModifiers;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_Executioner_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityExecutioner"; //TODO
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	AimandCritModifiers = new class 'X2Effect_Executioner_AP';
	AimandCritModifiers.BuildPersistentEffect (1, true, true);
	AimandCritModifiers.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (AimandCritModifiers);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}


static function X2AbilityTemplate AddTacticalSenseAbility()
{
	local X2AbilityTemplate				Template;
	local X2Effect_TacticalSense		MyDefModifier;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_TacticalSense_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityBD_TacticalSense_LW"; //TODO
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.bIsPassive = true;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	MyDefModifier = new class 'X2Effect_TacticalSense';
	MyDefModifier.BuildPersistentEffect (1, true, true);
	MyDefModifier.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (MyDefModifier);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}


static function X2AbilityTemplate AddInfighterAbility()
{
	local X2AbilityTemplate						Template;
	local X2Effect_Infighter					DodgeBonus;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_Infighter_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityInfighter"; //TODO
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	DodgeBonus = new class 'X2Effect_Infighter';
	DodgeBonus.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	DodgeBonus.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(DodgeBonus);
	Template.bcrossclasseligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  No visualization
	return Template;
}

static function X2AbilityTemplate AddDepthPerceptionAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_DepthPerception		AttackBonus;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_DepthPerception_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityDepthPerception"; //TODO
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	//Template.bIsPassive = true;
	AttackBonus = new class 'X2Effect_DepthPerception';
	AttackBonus.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	AttackBonus.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(AttackBonus);
	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

static function X2AbilityTemplate AddLightEmUpAbility()
{
	local X2AbilityTemplate                 Template;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost_ActionPoints        ActionPointCost;
	local array<name>                       SkipExclusions;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Condition_Visibility            VisibilityCondition;

	// Macro to do localisation and stuffs
	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_LightEmUp_LW');

	// Icon Properties
	Template.bDontDisplayInAbilitySummary = false;
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityLightEmUp"; //TODO
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.STANDARD_SHOT_PRIORITY;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.DisplayTargetHitChance = true;
	Template.AbilitySourceName = 'eAbilitySource_Standard';                                       // color of the icon
	// Activated by a button press; additionally, tells the AI this is an activatable
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	SkipExclusions.AddItem(class'X2AbilityTemplateManager'.default.DisorientedName);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Targeting Details
	// Can only shoot visible enemies
	VisibilityCondition = new class'X2Condition_Visibility';
	VisibilityCondition.bRequireGameplayVisible = true;
	VisibilityCondition.bAllowSquadsight = true;
	Template.AbilityTargetConditions.AddItem(VisibilityCondition);
	// Can't target dead; Can't target friendlies
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	// Can't shoot while dead
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	// Only at single targets that are in range.
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// Action Point
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false; //THIS IS THE DIFFERENCE BETWEEN STANDARD SHOT
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Ammo
	AmmoCost = new class'X2AbilityCost_Ammo';
	AmmoCost.iAmmo = 1;
	Template.AbilityCosts.AddItem(AmmoCost);
	Template.bAllowAmmoEffects = true; //

	// Weapon Upgrade Compatibility
	Template.bAllowFreeFireWeaponUpgrade = true;                        // Flag that permits action to become 'free action' via 'Hair Trigger' or similar upgrade / effects

	//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	//  Various Soldier ability specific effects - effects check for the ability before applying
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect());

	// Damage Effect
	Template.AddTargetEffect(default.WeaponUpgradeMissDamage);

	// Hit Calculation (Different weapons now have different calculations for range)
	Template.AbilityToHitCalc = default.SimpleStandardAim;
	Template.AbilityToHitOwnerOnMissCalc = default.SimpleStandardAim;

	// Targeting Method
	Template.TargetingMethod = class'X2TargetingMethod_OverTheShoulder';
	Template.bUsesFiringCamera = true;
	Template.CinescriptCameraType = "StandardGunFiring";

	Template.AssociatedPassives.AddItem('HoloTargeting');

	// MAKE IT LIVE!
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalAbility_BuildInterruptGameState;

	Template.bDisplayInUITooltip = true;
	Template.bDisplayInUITacticalText = true;

	KnockbackEffect = new class'X2Effect_Knockback';
	KnockbackEffect.KnockbackDistance = 2;
	Template.AddTargetEffect(KnockbackEffect);

	Template.OverrideAbilities.AddItem('StandardShot');

	return Template;
}



static function X2AbilityTemplate AddTraverseFireAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_TraverseFire			ActionEffect;

	`CREATE_X2ABILITY_TEMPLATE (Template, 'BD_TraverseFire_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityTraverseFire"; //TODO
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	ActionEffect = new class 'X2Effect_TraverseFire';
	ActionEffect.SetDisplayInfo (ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	ActionEffect.BuildPersistentEffect(1, true);
	Template.AddTargetEffect(ActionEffect);
	Template.bCrossClassEligible = false;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	// Visualization handled in Effect
	return Template;
}

static function X2AbilityTemplate AddLockedOnAbility()
{
	local X2AbilityTemplate         Template;
	local X2Effect_LockedOn		LockedOnEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_LockedOn_LW');
	Template.IconImage = "img:///UILibrary_LWAlienPack.LW_AbilityLockedOn"; //TODO
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	Template.bcrossclasseligible = false;
	LockedOnEffect = new class'X2Effect_LockedOn';
	LockedOnEffect.BuildPersistentEffect(1, true, true,, eGameRule_TacticalGameStart);
	LockedOnEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(LockedOnEffect);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}


static function X2AbilityTemplate AddLightningReflexes_LWAbility()
{
	local X2AbilityTemplate                 Template;
	local X2Effect_LightningReflexes_LW	PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_LightningReflexes_LW');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_lightningreflexes";
	Template.Hostility = eHostility_Neutral;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	PersistentEffect = new class'X2Effect_LightningReflexes_LW';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.bcrossclasseligible = false;
	return Template;
}


static function X2AbilityTemplate AddAreaSuppressionAbility()
{
	local X2AbilityTemplate								Template;
	local X2AbilityCost_Ammo							AmmoCost;
	local X2AbilityCost_ActionPoints					ActionPointCost;
	local X2AbilityMultiTarget_Radius					RadiusMultiTarget;
	local X2Effect_ReserveActionPoints					ReserveActionPointsEffect;
	local X2Condition_UnitInventory						InventoryCondition, InventoryCondition2;
	local X2Effect_AreaSuppression						SuppressionEffect;
	local X2AbilityTarget_Single						PrimaryTarget;
	local AbilityGrantedBonusRadius						DangerZoneBonus;
	local X2Condition_UnitProperty						ShooterCondition;
	local X2Condition_UnitEffects						SuppressedCondition;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_AreaSuppression_LW');
	Template.IconImage = "img:///UILibrary_LW_PerkPack.LW_AreaSuppression";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.Hostility = eHostility_Offensive;
	Template.bDisplayInUITooltip = false;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.bCrossClassEligible = false;
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.ActivationSpeech='Suppressing';
	Template.bIsASuppressionEffect = true;

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);	
	Template.AddShooterEffectExclusions();
	SuppressedCondition = new class'X2Condition_UnitEffects';
	SuppressedCondition.AddExcludeEffect(class'X2Effect_Suppression'.default.EffectName, 'AA_UnitIsSuppressed');
	SuppressedCondition.AddExcludeEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsSuppressed');
	Template.AbilityShooterConditions.AddItem(SuppressedCondition);

	ShooterCondition=new class'X2Condition_UnitProperty';
	ShooterCondition.ExcludeConcealed = true;
	Template.AbilityShooterConditions.AddItem(ShooterCondition);

	Template.AssociatedPassives.AddItem('HoloTargeting');

	InventoryCondition = new class'X2Condition_UnitInventory';
	InventoryCondition.RelevantSlot=eInvSlot_PrimaryWeapon;
	InventoryCondition.ExcludeWeaponCategory = 'shotgun';
	Template.AbilityShooterConditions.AddItem(InventoryCondition);

	InventoryCondition2 = new class'X2Condition_UnitInventory';
	InventoryCondition2.RelevantSlot=eInvSlot_PrimaryWeapon;
	InventoryCondition2.ExcludeWeaponCategory = 'sniper_rifle';
	Template.AbilityShooterConditions.AddItem(InventoryCondition2);

	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = default.AREA_SUPPRESSION_AMMO_COST;
	Template.AbilityCosts.AddItem(AmmoCost);

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bConsumeAllPoints = true;   //  this will guarantee the unit has at least 1 action point
	ActionPointCost.bFreeCost = true;           //  ReserveActionPoints effect will take all action points away
	Template.AbilityCosts.AddItem(ActionPointCost);

	ReserveActionPointsEffect = new class'X2Effect_ReserveActionPoints';
	ReserveActionPointsEffect.ReserveType = 'Suppression';
	ReserveActionPointsEffect.NumPoints = default.AREA_SUPPRESSION_MAX_SHOTS;
	Template.AddShooterEffect(ReserveActionPointsEffect);

	Template.AbilityTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);
	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);

	PrimaryTarget = new class'X2AbilityTarget_Single';
	PrimaryTarget.OnlyIncludeTargetsInsideWeaponRange = false;
	PrimaryTarget.bAllowInteractiveObjects = false;
	PrimaryTarget.bAllowDestructibleObjects = false;
	PrimaryTarget.bIncludeSelf = false;
	PrimaryTarget.bShowAOE = true;
	Template.AbilityTargetSTyle = PrimaryTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	RadiusMultiTarget.bAllowDeadMultiTargetUnits = false;
	RadiusMultiTarget.bExcludeSelfAsTargetIfWithinRadius = true;
	RadiusMultiTarget.bUseWeaponRadius = false;
	RadiusMultiTarget.ftargetradius = default.AREA_SUPPRESSION_RADIUS;
	
	DangerZoneBonus.RequiredAbility = 'DangerZone';
	DangerZoneBonus.fBonusRadius = default.DANGER_ZONE_BONUS_RADIUS;
	RadiusMultiTarget.AbilityBonusRadii.AddItem (DangerZoneBonus);
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;
	
	Template.AbilityMultiTargetConditions.AddItem(default.LivingHostileUnitOnlyProperty);

	SuppressionEffect = new class'X2Effect_AreaSuppression';
	SuppressionEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	SuppressionEffect.bRemoveWhenTargetDies = true;
	SuppressionEffect.bRemoveWhenSourceDamaged = true;
	SuppressionEffect.bBringRemoveVisualizationForward = true;
	SuppressionEffect.DuplicateResponse=eDupe_Allow;
	SuppressionEffect.SetDisplayInfo(ePerkBuff_Penalty, Template.LocFriendlyName, class'X2Ability_GrenadierAbilitySet'.default.SuppressionTargetEffectDesc, Template.IconImage);
	SuppressionEffect.SetSourceDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, class'X2Ability_GrenadierAbilitySet'.default.SuppressionSourceEffectDesc, Template.IconImage);
	Template.AddTargetEffect(SuppressionEffect);
	Template.AddTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	Template.AddMultiTargetEffect(SuppressionEffect);
	Template.AddMultiTargetEffect(class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect());
	
	Template.AdditionalAbilities.AddItem('BD_AreaSuppressionShot_LW');

	Template.TargetingMethod = class'X2TargetingMethod_AreaSuppression';

	Template.BuildVisualizationFn = AreaSuppression_BuildVisualization_LW;
	Template.BuildAppliedVisualizationSyncFn = AreaSuppression_BuildVisualizationSync;
	Template.CinescriptCameraType = "StandardSuppression";	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;
}

//Adds multitarget visualization
simulated function AreaSuppression_BuildVisualization_LW(XComGameState VisualizeGameState)
{
	local XComGameStateHistory			History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference          InteractingUnitRef;
	local VisualizationActionMetadata   EmptyTrack;
	local VisualizationActionMetadata   BuildTrack;
	local XComGameState_Ability         Ability;
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
	
	class'X2Action_ExitCover'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded);
	class'X2Action_StartSuppression'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded);
	
	//****************************************************************************************
	//Configure the visualization track for the primary target

	InteractingUnitRef = Context.InputContext.PrimaryTarget;
	Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
	BuildTrack = EmptyTrack;
	BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
	SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded));
	SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Ability.GetMyTemplate().LocFlyOverText, '', eColor_Bad);
	if (XComGameState_Unit(BuildTrack.StateObject_OldState).ReserveActionPoints.Length != 0 && XComGameState_Unit(BuildTrack.StateObject_NewState).ReserveActionPoints.Length == 0)
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(none, class'XLocalizedData'.default.OverwatchRemovedMsg, '', eColor_Bad);
	}

	//Configure for the rest of the targets in AOE Suppression
	if (Context.InputContext.MultiTargets.Length > 0)
	{
		foreach Context.InputContext.MultiTargets(InteractingUnitRef)
		{
			Ability = XComGameState_Ability(History.GetGameStateForObjectID(Context.InputContext.AbilityRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1));
			BuildTrack = EmptyTrack;
			BuildTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
			BuildTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
			BuildTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);
			SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded));
			SoundAndFlyOver.SetSoundAndFlyOverParameters(None, Ability.GetMyTemplate().LocFlyOverText, '', eColor_Bad);
			if (XComGameState_Unit(BuildTrack.StateObject_OldState).ReserveActionPoints.Length != 0 && XComGameState_Unit(BuildTrack.StateObject_NewState).ReserveActionPoints.Length == 0)
			{
				SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(BuildTrack, Context, false, BuildTrack.LastActionAdded));
				SoundAndFlyOver.SetSoundAndFlyOverParameters(none, class'XLocalizedData'.default.OverwatchRemovedMsg, '', eColor_Bad);
			}
		}
	}
}

simulated function AreaSuppression_BuildVisualizationSync(name EffectName, XComGameState VisualizeGameState, out VisualizationActionMetadata BuildTrack)
{
	local X2Action_ExitCover ExitCover;

	if (EffectName == class'X2Effect_AreaSuppression'.default.EffectName)
	{
		ExitCover = X2Action_ExitCover(class'X2Action_ExitCover'.static.AddToVisualizationTree( BuildTrack, VisualizeGameState.GetContext(), false, BuildTrack.LastActionAdded ));
		ExitCover.bIsForSuppression = true;

		class'X2Action_StartSuppression'.static.AddToVisualizationTree( BuildTrack, VisualizeGameState.GetContext(), false, BuildTrack.LastActionAdded );
	}
}


static function X2AbilityTemplate AreaSuppressionShot_LW()
{
	local X2AbilityTemplate                 Template;	
	local X2AbilityCost_ReserveActionPoints ReserveActionPointCost;
	local X2AbilityToHitCalc_StandardAim    StandardAim;
	local X2Condition_Visibility            TargetVisibilityCondition;
	local X2AbilityTrigger_EventListener    Trigger;
	local X2Condition_UnitEffectsWithAbilitySource TargetEffectCondition;
	local X2Effect_RemoveAreaSuppressionEffect	RemoveAreaSuppression;
	local X2Effect                          ShotEffect;
	local X2AbilityCost_Ammo				AmmoCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'BD_AreaSuppressionShot_LW');

	Template.bDontDisplayInAbilitySummary = true;
	ReserveActionPointCost = new class'X2AbilityCost_ReserveActionPoints';
	ReserveActionPointCost.iNumPoints = 1;
	ReserveActionPointCost.AllowedTypes.AddItem('Suppression');
	Template.AbilityCosts.AddItem(ReserveActionPointCost);
	
	AmmoCost = new class'X2AbilityCost_Ammo';	
	AmmoCost.iAmmo = default.AREA_SUPPRESSION_SHOT_AMMO_COST;
	Template.AbilityCosts.AddItem(AmmoCost);

	StandardAim = new class'X2AbilityToHitCalc_StandardAim';
	StandardAim.BuiltInHitMod = default.AREA_SUPPRESSION_LW_SHOT_AIM_BONUS;
	StandardAim.bReactionFire = true;

	Template.AbilityToHitCalc = StandardAim;
	Template.AbilityToHitOwnerOnMissCalc = StandardAim;

	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);

	TargetEffectCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	TargetEffectCondition.AddRequireEffect(class'X2Effect_AreaSuppression'.default.EffectName, 'AA_UnitIsNotSuppressed');
	Template.AbilityTargetConditions.AddItem(TargetEffectCondition);

	TargetVisibilityCondition = new class'X2Condition_Visibility';	
	TargetVisibilityCondition.bRequireGameplayVisible = true;
	Template.AbilityTargetConditions.AddItem(TargetVisibilityCondition);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.bAllowAmmoEffects = true;

	// this handles the logic for removing just from the target (if should continue), or removing from all targets if running out of ammo
	RemoveAreaSuppression = new class'X2Effect_RemoveAreaSuppressionEffect';
	RemoveAreaSuppression.EffectNamesToRemove.AddItem(class'X2Effect_AreaSuppression'.default.EffectName);
	RemoveAreaSuppression.bCheckSource =  true;
	RemoveAreaSuppression.SetupEffectOnShotContextResult(true, true);
	Template.AddTargetEffect(RemoveAreaSuppression);

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	//Trigger on movement - interrupt the move
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.EventID = 'ObjectMoved';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.Filter = eFilter_None;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.TypicalOverwatchListener;
	Template.AbilityTriggers.AddItem(Trigger);

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_supression";
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_LIEUTENANT_PRIORITY;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;

	//don't want to exit cover, we are already in suppression/alert mode.
	Template.bSkipExitCoverWhenFiring = true;

	Template.bAllowFreeFireWeaponUpgrade = true;	
//  Put holo target effect first because if the target dies from this shot, it will be too late to notify the effect.
	ShotEffect = class'X2Ability_GrenadierAbilitySet'.static.HoloTargetEffect();
	ShotEffect.TargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());
	Template.AddTargetEffect(ShotEffect);
	//  Various Soldier ability specific effects - effects check for the ability before applying	
	ShotEffect = class'X2Ability_GrenadierAbilitySet'.static.ShredderDamageEffect();
	ShotEffect.TargetConditions.AddItem(class'X2Ability_DefaultAbilitySet'.static.OverwatchTargetEffectsCondition());
	Template.AddTargetEffect(ShotEffect);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotLostSpawnIncreasePerUse;

	return Template;	
}

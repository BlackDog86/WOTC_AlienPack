class X2EventListener_NoInspiration extends X2EventListener config(NoInspiration);

var config array<name> DoNotInspireTheseTechs;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(NoInspirationListener());

    return Templates;
}

static function X2EventListenerTemplate NoInspirationListener()
{
    local X2EventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'DoNotInspireTechs');

    //    Should the Event Listener listen for the event during tactical missions?
    Template.RegisterInTactical = false;
    //    Should listen to the event while on Avenger?
    Template.RegisterInStrategy = true;
    Template.AddEvent('CanTechBeInspired', NoInspirationListenerFn);

    return Template;
}

static final function EventListenerReturn NoInspirationListenerFn(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
    local XComLWTuple               Tuple;
    local XComGameState_Tech		TechState;
	
    Tuple = XComLWTuple(EventData);

    if (Tuple == none)
    {
        return ELR_NoInterrupt;
    }

    if (Tuple.Id != 'CanTechBeInspired')
    {
        return ELR_NoInterrupt;
    }

    TechState = XComGameState_Tech(EventSource);

    if (TechState == none)
    {
        return ELR_NoInterrupt;
    }

	if(default.DoNotInspireTheseTechs.Find(TechState.GetMyTemplateName()) != INDEX_NONE)
	{
        Tuple.Data[0].b = false;
    }

    return ELR_NoInterrupt;
}
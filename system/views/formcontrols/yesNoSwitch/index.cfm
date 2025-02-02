<cfscript>
	inputName    = args.name         ?: "";
	inputId      = args.id           ?: "";
	inputClass   = args.class        ?: "";
	defaultValue = args.defaultValue ?: "";
	disabled     = isTrue( args.disabled ?: "" );

	value  = event.getValue( name=inputName, defaultValue=defaultValue );
	if ( not IsSimpleValue( value ) ) {
		value = "";
	}

	checked = IsBoolean( value ) and value;
</cfscript>

<cfoutput>
	<input class="#inputClass# ace ace-switch ace-switch-6" type="checkbox" id="#inputId#" name="#inputName#"<cfif checked> checked="checked"</cfif> value="1" tabindex="#getNextTabIndex()#" <cfif disabled> disabled</cfif>>
	<span class="lbl"></span>
</cfoutput>
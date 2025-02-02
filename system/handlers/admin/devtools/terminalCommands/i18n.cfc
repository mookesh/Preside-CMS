component hint="Manage Preside i18n" extends="preside.system.base.Command" {

	property name="jsonRpc2"             inject="JsonRpc2";
	property name="i18n"                 inject="i18n";
	property name="presideObjectService" inject="PresideObjectService";
	property name="enum"                 inject="coldbox:setting:enum";

	private function index( event, rc, prc ) {
		var params          = jsonRpc2.getRequestParams();
		var validOperations = [ "object", "enum" ];

		params = IsArray( params.commandLineArgs ?: "" ) ? params.commandLineArgs : [];

		if ( !ArrayLen( params ) || !ArrayFindNoCase( validOperations, params[ 1 ] ) ) {
			var message = newLine();

			message &= writeText( text="Usage: ", type="info", bold=true );
			message &= writeText( "i18n [operation]" );
			message &= newLine();

			message &= writeText( "Valid operations:" );
			message &= newLine();

			message &= writeText( text="    object ", type="info", bold=true );
			message &= writeText( text=": Lists all i18n of an object properties.", newLine=true );

			message &= writeText( text="    enum   ", type="info", bold=true );
			message &= writeText( text=": Lists all i18n of an enum keys.", newLine=true );

			return message;
		}

		return runEvent(
			  event          = "admin.devtools.terminalCommands.i18n.#params[ 1 ]#List"
			, private        = true
			, prePostExempt  = true
			, eventArguments = {
				args = {
					params = params
				}
			  }
		);
	}

	private any function objectList( event, rc, prc, args ) {
		var message = newLine();
		var titles  = "";

		var objectName = args.params[ 2 ] ?: "";
		var context    = isEmptyString( args.params[ 3 ] ?: "" ) ? "" : "." & args.params[ 3 ] ;

		try {
			var rows  = [];
			var props = presideObjectService.getObjectProperties( objectName=objectName );

			for ( var propertyName in props ) {
				var cols       = [];
				var uri        = presideObjectService.getResourceBundleUriRoot( objectName=objectName ) & "field.#propertyName##context#.title";
				var translated = i18n.translateResource( uri=uri, defaultValue="" );
				var type       = isEmptyString( translated ) ? "error" : "success";

				ArrayAppend( cols, {
					  text = propertyName
					, type = type
				} );
				ArrayAppend( cols, {
					  text = uri
					, type = type
				} );
				ArrayAppend( cols, {
					  text = isEmptyString( translated ) ? "(No value)" : translated
					, type = type
				} );

				ArrayAppend( rows, cols );

				var defaultUri        = "cms:preside-objects.default.field.#propertyName#.title";
				var defaultTranslated = i18n.translateResource( uri=defaultUri, defaultValue="" );

				if ( !isEmptyString( defaultTranslated ) ) {
					cols = [];

					ArrayAppend( cols, "" );
					ArrayAppend( cols, {
						  text = defaultUri
					} );
					ArrayAppend( cols, {
						  text = defaultTranslated
					} );

					ArrayAppend( rows, cols );
				}
			}

			message &= writeTable(
				  header = [ "Property", "URI", "Translation" ]
				, rows   = rows
			);
		} catch ( any e ) {
			message &= writeText( text=( e.message ?: "" ), newLine=true );
		}

		return message;
	}

	private any function enumList( event, rc, prc, args ) {
		var message = newLine();
		var titles  = "";

		var enumName = args.params[ 2 ] ?: "";

		try {
			var rows  = [];
			var enums = enum[ enumName ] ?: [];

			if ( ArrayLen( enums ) ) {
				for ( var enumKey in enums ) {
					var cols       = [];
					var uri        = "enum.#enumName#:#enumKey#.label";
					var translated = i18n.translateResource( uri=uri, defaultValue="" );
					var type       = isEmptyString( translated ) ? "error" : "success";

					ArrayAppend( cols, {
						  text = enumKey
						, type = type
					} );
					ArrayAppend( cols, {
						  text = uri
						, type = type
					} );
					ArrayAppend( cols, {
						  text = isEmptyString( translated ) ? "(No value)" : translated
						, type = type
					} );

					ArrayAppend( rows, cols );
				}

				message &= writeTable(
					  header = [ "Enum", "URI", "Translation" ]
					, rows   = rows
				);
			} else {
				message &= writeText( text="No enums found.", newLine=true );
			}
		} catch ( any e ) {
			message &= writeText( text=( e.message ?: "" ), newLine=true );
		}

		return message;
	}

}
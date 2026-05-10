/// GMS 2.3.0 Destructors
/// @author Zach Reedy <DatZach>
/// @author Juju Adams <JujuAdams>
/// @author Torin Freimiller <Nommiin>

/// @ignore [MAJOR.MINOR.PATCH]
#macro DTOR_VERSION		"1.3.1"
/// @ignore
#macro DTOR_ALERT		true
/// @ignore Log alerts in the time_source loop.
#macro DTOR_ALERT_LOOP	true
/// @ignore
#macro DTOR_ERROR		true
/// @ignore 
#macro DTOR_STRICT_MODE	true

/// @ignore Time to wait before checking for dead references, in frames. (Default: 5)
#macro DTOR_TIME		5
/// @ignore Threshold for number of destructors before logging a warning about potential performance issues. (Default: 100)
#macro DTOR_THRESHOLD	100

show_debug_message($"Dtor Alert:: v{DTOR_VERSION} loaded. Made by Zach Reedy, Juju Adams, and Torin Freimiller.");
show_debug_message("Dtor Alert:: Alerts: {DTOR_ALERT}, Errors: {DTOR_ERROR}, Strict Mode: {DTOR_STRICT_MODE}, Check Time: {DTOR_TIME} frames.");

/// @ignore
enum DtorType
{
    Function,
    Script,
    
    List,
    Map,
    Grid,
    Priority,
    Queue,
    Stack,
    Buffer,
    
    Sprite,
    Surface,
    VertexBuffer,
    VertexFormat,
    
    Path,
    AnimCurve,
    Instance
}

/// @ignore
/// @desc Internal function to log destructor alerts when DTOR_ALERT is enabled.
/// @param {String} msg The message to log.
function __dtor_alert(_msg)
{
	if (DTOR_ALERT) show_debug_message($"Dtor Alert:: {_msg}");
}

/// @ignore
/// @desc Internal function to log destructor errors when DTOR_ERROR is enabled. If DTOR_STRICT_MODE is also enabled, this will crash the game with an error message to avoid silent failures.
/// @param {String} msg The message to log.
function __dtor_error(_msg)
{
	static __gml_global_script_prefix = "gml_GlobalScript_";
	static __gml_object_prefix = "gml_Object_";

	if (DTOR_ERROR)
	{
		var _origin = "unknown:0";

		// Try to get the caller's script and line number for better debug messages.
		var _stack = debug_get_callstack(2);
		if (is_array(_stack) )
		{
			if (array_length(_stack) > 1) _origin = _stack[1];
			else if (array_length(_stack) > 0) _origin = _stack[0];
		}

		// Remove common GML prefixes to improve readability of debug messages.
		if (string_starts_with(_origin, __gml_global_script_prefix) ) { _origin = string_delete(_origin, 1, 17); }
		if (string_starts_with(_origin, __gml_object_prefix) ) { _origin = string_delete(_origin, 1, 11); }

		show_debug_message($"Dtor Error:: {_origin}:: {_msg}");

		// If strict mode is enabled crash the game with an error message to avoid silent failures.
		if (DTOR_STRICT_MODE) { show_error($"Dtor Fatal Error:: {_origin}:: {_msg}", true); }
	}
}

/// @ignore
/// @desc Validates registration arguments for dtor(). Returns true when valid.
/// @param {enum.DtorType} type
/// @param {Any} value
/// @param {Any} reference
function __dtor_validate_registration(_type, _value, _ref)
{
	var _type_valid = false;
	switch(_type)
	{
		case DtorType.Function:
		case DtorType.Script:
		case DtorType.List:
		case DtorType.Map:
		case DtorType.Grid:
		case DtorType.Priority:
		case DtorType.Queue:
		case DtorType.Stack:
		case DtorType.Buffer:
		case DtorType.Sprite:
		case DtorType.Surface:
		case DtorType.VertexBuffer:
		case DtorType.VertexFormat:
		case DtorType.Path:
		case DtorType.AnimCurve:
		case DtorType.Instance:
			_type_valid = true;
		break;
	}

	if (!_type_valid)
	{
		__dtor_error($"Invalid destructor type '{_type}'.");
		return false;
	}

	if (is_undefined(_ref) || is_ptr(_ref) )
	{
		__dtor_error("Invalid destructor reference. '_ref' must be a live struct/instance reference.");
		return false;
	}

	if (is_undefined(_value) )
	{
		__dtor_error("Invalid destructor value. '_value' cannot be undefined.");
		return false;
	}

	switch(_type)
	{
		case DtorType.Function:
			if (!is_method(_value) && !is_callable(_value) )
			{
				__dtor_error("DtorType.Function requires a callable function value.");
				return false;
			}
		break;

		case DtorType.Script:
			if (!is_real(_value) || asset_get_type(_value) != asset_script)
			{
				__dtor_error("DtorType.Script requires a valid script asset id.");
				return false;
			}
		break;
	}

	return true;
}

/// @ignore
/// @desc Manager for destructors. This is responsible for keeping track of all registered destructors and checking for dead references on each step of the time source.
function __Dtor()
{
	#region Private
	/// @ignore
	static __list = ds_list_create();
	/// @ignore
	static __size = 0;
	/// @ignore
	static __index = 0;

	/// @ignore
	/// @desc Internal function that runs on each step of the time source to check for dead references and execute their destructors.
	static __update = function()
	{
		if (__size > 0)
		{
			if (__index >= __size) __index = 0;

			var _inst = __list[| __index];
			// Still alive
			if (!weak_ref_alive(_inst.reference) )
			{
				if (DTOR_ALERT_LOOP)
				{
					__dtor_alert($"Executing Dtor index {__index} of type {_inst.type} with value {_inst.value} and option {_inst.option}");
				}

				switch(_inst.type)
				{
					// Methods
					case DtorType.Function:		_inst.value(_inst.option);					break;
					case DtorType.Script:		script_execute(_inst.value, _inst.option);	break;
					
					case DtorType.List:			ds_list_destroy(_inst.value);		break;
					case DtorType.Map:			ds_map_destroy(_inst.value);		break;
					case DtorType.Grid:			ds_grid_destroy(_inst.value);		break;
					case DtorType.Priority:		ds_priority_destroy(_inst.value);	break;
					case DtorType.Queue:		ds_queue_destroy(_inst.value);		break;
					case DtorType.Stack:		ds_stack_destroy(_inst.value);		break;
					case DtorType.Buffer:		buffer_delete(_inst.value);			break;
					
					case DtorType.Sprite:		sprite_delete(_inst.value);			break;
					case DtorType.Surface:		surface_free(_inst.value);			break;
					case DtorType.VertexBuffer:	vertex_delete_buffer(_inst.value);	break;
					case DtorType.VertexFormat:	vertex_format_delete(_inst.value);	break;
					
					case DtorType.Path:			path_delete(_inst.value);			break;
					case DtorType.AnimCurve:	animcurve_destroy(_inst.value);		break;
					case DtorType.Instance:		instance_destroy(_inst.value);		break;
				}
				
				// Remove from list
				ds_list_delete(__list, __index);
				__size = __size - 1;
				if (__size <= 0)
				{
					time_source_stop(__step);
					if (DTOR_ALERT_LOOP) { __dtor_alert("No more Dtors in queue, stopping time source."); }
				}
				if (DTOR_ALERT_LOOP) { __dtor_alert($"Dtor Deleted index {__index} of type {_inst.type} with value {_inst.value} and option {_inst.option}"); }

				__index = (__index - 1 < 0 || __index - 1 >= __size) ? 0 : __index - 1;
			}
			// Alive
			else
			{
				__index = __index + 1;
				if (__index >= __size) __index = 0;
			}
		}
	};
	
	/// @ignore
	static __step = time_source_create(time_source_global, DTOR_TIME, time_source_units_frames, method(static_get(__Dtor), __update), [], -1);

	#endregion

	/// @desc Add a destructor instance to the manager.
	/// @param {DtorInstance} dtor_instance The destructor instance to add.
	static Add = function(_dtor_instance)
	{
		ds_list_add(__list, _dtor_instance);
		__size++;

		__dtor_alert($"Added Dtor of type {_dtor_instance.type} with value {_dtor_instance.value} and option {_dtor_instance.option}");

		if (__size >= DTOR_THRESHOLD)
		{
			__dtor_alert($"Warning: Dtor queue size reached {__size}. Large queues increase time before individual destructors are checked.");
		}
	};

	// Start time source
	time_source_start(__step);
}

/// @ignore
/// @param {enum.DtorType} type
/// @param {Any} value
/// @param {Any} [options]
/// @param {Any} [reference]
function DtorInstance(_type, _value, _option, _ref) constructor
{
	/// @ignore Bound Methods to this dummy struct.
	static __dummy = {};
	
	reference = weak_ref_create(_ref);
	type = _type;
	
	// Not bound
	value = (is_method(_value) ) ? method(__dummy, _value) : _value;
	option = _option;
}

/// @param {enum.DtorType} type
/// @param {Any} value
/// @param {Any} [options]
/// @param {Any} [reference]
function dtor(_type, _value, _option, _ref=self)
{
	if (!__dtor_validate_registration(_type, _value, _ref) ) return;

	var _instance = new DtorInstance(_type, _value, _option, _ref);
	__dtor_alert($"Registering Dtor of type {_type} with value {_value} and option {_option}");
	
	// Add to the manager
	__Dtor.Add(_instance);
	
	// Validate time source exists before attempting to use it
	if (!time_source_exists(__Dtor.__step) )
	{
		__dtor_error("Internal time source was destroyed or is invalid. Cannot restart destructor manager.");
		return;
	}
	
	// Re-start timesource
	if (time_source_get_state(__Dtor.__step) == time_source_state_stopped)
	{
		time_source_start(__Dtor.__step);
	}
}

// This is just for debugging purposes to allow access to the destructor manager in debug mode.
if (debug_mode)
{
	/// @ignore
	global.__Dtor = static_get(__Dtor);
}

script_execute(__Dtor);

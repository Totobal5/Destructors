function destructors_test_function_subject(_context) constructor
{
	dtor(DtorType.Function, function(_payload) {
		_payload.called = true;
		_payload.received = _payload.expected;
	}, _context);
}

function destructors_test_function_issue3_anon_subject(_context) constructor
{
	dtor(DtorType.Function, function(_payload) {
		_payload.called_anon = true;
	}, _context);
}

function destructors_test_function_issue3_var_subject(_context) constructor
{
	var _func = function(_payload) {
		_payload.called_var = true;
	};
	dtor(DtorType.Function, _func, _context);
}

function destructors_test_function_issue3_named_subject(_context) constructor
{
	function _func(_payload)
	{
		_payload.called_named = true;
	}
	dtor(DtorType.Function, _func, _context);
}

function destructors_test_list_subject(_context) constructor
{
	_context.list_handle = ds_list_create();
	dtor(DtorType.List, _context.list_handle);
}

function destructors_test_map_subject(_context) constructor
{
	_context.map_handle = ds_map_create();
	dtor(DtorType.Map, _context.map_handle);
}

function destructors_test_grid_subject(_context) constructor
{
	_context.grid_handle = ds_grid_create(2, 2);
	dtor(DtorType.Grid, _context.grid_handle);
}

function destructors_test_priority_subject(_context) constructor
{
	_context.priority_handle = ds_priority_create();
	dtor(DtorType.Priority, _context.priority_handle);
}

function destructors_test_queue_subject(_context) constructor
{
	_context.queue_handle = ds_queue_create();
	dtor(DtorType.Queue, _context.queue_handle);
}

function destructors_test_stack_subject(_context) constructor
{
	_context.stack_handle = ds_stack_create();
	dtor(DtorType.Stack, _context.stack_handle);
}

function destructors_test_buffer_subject(_context) constructor
{
	_context.buffer_handle = buffer_create(256, buffer_fixed, 1);
	dtor(DtorType.Buffer, _context.buffer_handle);
}

function destructors_test_path_subject(_context) constructor
{
	_context.path_handle = path_add();
	dtor(DtorType.Path, _context.path_handle);
}

function destructors_test_animcurve_subject(_context) constructor
{
	_context.animcurve_handle = animcurve_create();
	dtor(DtorType.AnimCurve, _context.animcurve_handle);
}


function destructors_test_script_subject(_context) constructor
{
	dtor(DtorType.Script, destructors_test_script_callback, _context);
}

function destructors_test_script_callback(_payload)
{
	_payload.called = true;
	_payload.received = _payload.expected;
}

function Destructors_Tests()
{
	var _suite = new CrispySuite("Destructors_Tests");

	// TEST: Function Destructor
	var _function_case = new CrispyCaseAsync("test_destructors_function_callback_runs_after_delete");
	var _function_context = {};
	_function_context.state = undefined;
	_function_context.subject = undefined;
	_function_context.frames = 0;
	_function_context.test_case = _function_case;

	_function_case.WaitBeginStep(function() {
		state = {
			called: false,
			expected: "function payload",
			received: undefined,
		};

		subject = new destructors_test_function_subject(state);
		delete subject;
		subject = undefined;
		return true;
	}, _function_context);

	_function_case.WaitStep(function() {
		++frames;
		if (frames < 6)
		{
			return false;
		}

		test_case.AssertTrue(state.called, "Function destructor should run after delete");
		test_case.AssertEqual(state.received, "function payload", "Function destructor should receive the registered option");
		return true;
	}, _function_context);
	_function_case.Timeout(10, "frames");
	_suite.AddCase(_function_case);

	// TEST: Function Destructor Issue #3 Regression
	var _function_issue3_case = new CrispyCaseAsync("test_destructors_function_issue3_patterns_execute_after_delete");
	var _function_issue3_context = {};
	_function_issue3_context.state = undefined;
	_function_issue3_context.subject_anon = undefined;
	_function_issue3_context.subject_var = undefined;
	_function_issue3_context.subject_named = undefined;
	_function_issue3_context.frames = 0;
	_function_issue3_context.test_case = _function_issue3_case;

	_function_issue3_case.WaitBeginStep(function() {
		state = {
			called_anon: false,
			called_var: false,
			called_named: false,
		};

		subject_anon = new destructors_test_function_issue3_anon_subject(state);
		subject_var = new destructors_test_function_issue3_var_subject(state);
		subject_named = new destructors_test_function_issue3_named_subject(state);

		delete subject_anon;
		delete subject_var;
		delete subject_named;
		subject_anon = undefined;
		subject_var = undefined;
		subject_named = undefined;

		return true;
	}, _function_issue3_context);

	_function_issue3_case.WaitStep(function() {
		++frames;
		if (frames < 20)
		{
			return false;
		}

		test_case.AssertTrue(state.called_anon, "Anonymous function destructor should execute after delete");
		test_case.AssertTrue(state.called_var, "Function variable destructor should execute after delete");
		test_case.AssertTrue(state.called_named, "Named local function destructor should execute after delete");
		return true;
	}, _function_issue3_context);
	_function_issue3_case.Timeout(30, "frames");
	_suite.AddCase(_function_issue3_case);

	// TEST: List Destructor
	var _list_case = new CrispyCaseAsync("test_destructors_list_is_destroyed_after_delete");
	var _list_context = {};
	_list_context.state = undefined;
	_list_context.subject = undefined;
	_list_context.list_handle = undefined;
	_list_context.frames = 0;
	_list_context.test_case = _list_case;

	_list_case.WaitBeginStep(function() {
		state = { list_handle: undefined };
		subject = new destructors_test_list_subject(state);
		list_handle = state.list_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _list_context);

	_list_case.WaitEndStep(function() {
		++frames;
		if (frames < 25)
		{
			return false;
		}

		test_case.AssertFalse(ds_exists(list_handle, ds_type_list), "List destructor should destroy the ds_list");
		return true;
	}, _list_context);
	_list_case.Timeout(35, "frames");
	_suite.AddCase(_list_case);

	// TEST: Map Destructor
	var _map_case = new CrispyCaseAsync("test_destructors_map_is_destroyed_after_delete");
	var _map_context = {};
	_map_context.state = undefined;
	_map_context.subject = undefined;
	_map_context.map_handle = undefined;
	_map_context.frames = 0;
	_map_context.test_case = _map_case;

	_map_case.WaitBeginStep(function() {
		state = { map_handle: undefined };
		subject = new destructors_test_map_subject(state);
		map_handle = state.map_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _map_context);

	_map_case.WaitEndStep(function() {
		++frames;
		if (frames < 30)
		{
			return false;
		}

		test_case.AssertFalse(ds_exists(map_handle, ds_type_map), "Map destructor should destroy the ds_map");
		return true;
	}, _map_context);
	_map_case.Timeout(40, "frames");
	_suite.AddCase(_map_case);

	// TEST: Grid Destructor
	var _grid_case = new CrispyCaseAsync("test_destructors_grid_is_destroyed_after_delete");
	var _grid_context = {};
	_grid_context.state = undefined;
	_grid_context.subject = undefined;
	_grid_context.grid_handle = undefined;
	_grid_context.frames = 0;
	_grid_context.test_case = _grid_case;

	_grid_case.WaitBeginStep(function() {
		state = { grid_handle: undefined };
		subject = new destructors_test_grid_subject(state);
		grid_handle = state.grid_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _grid_context);

	_grid_case.WaitEndStep(function() {
		++frames;
		if (frames < 35)
		{
			return false;
		}

		test_case.AssertFalse(ds_exists(grid_handle, ds_type_grid), "Grid destructor should destroy the ds_grid");
		return true;
	}, _grid_context);
	_grid_case.Timeout(45, "frames");
	_suite.AddCase(_grid_case);

	// TEST: Priority Destructor
	var _priority_case = new CrispyCaseAsync("test_destructors_priority_is_destroyed_after_delete");
	var _priority_context = {};
	_priority_context.state = undefined;
	_priority_context.subject = undefined;
	_priority_context.priority_handle = undefined;
	_priority_context.frames = 0;
	_priority_context.test_case = _priority_case;

	_priority_case.WaitBeginStep(function() {
		state = { priority_handle: undefined };
		subject = new destructors_test_priority_subject(state);
		priority_handle = state.priority_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _priority_context);

	_priority_case.WaitEndStep(function() {
		++frames;
		if (frames < 40)
		{
			return false;
		}

		test_case.AssertFalse(ds_exists(priority_handle, ds_type_priority), "Priority destructor should destroy the ds_priority");
		return true;
	}, _priority_context);
	_priority_case.Timeout(50, "frames");
	_suite.AddCase(_priority_case);

	// TEST: Queue Destructor
	var _queue_case = new CrispyCaseAsync("test_destructors_queue_is_destroyed_after_delete");
	var _queue_context = {};
	_queue_context.state = undefined;
	_queue_context.subject = undefined;
	_queue_context.queue_handle = undefined;
	_queue_context.frames = 0;
	_queue_context.test_case = _queue_case;

	_queue_case.WaitBeginStep(function() {
		state = { queue_handle: undefined };
		subject = new destructors_test_queue_subject(state);
		queue_handle = state.queue_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _queue_context);

	_queue_case.WaitEndStep(function() {
		++frames;
		if (frames < 45)
		{
			return false;
		}

		test_case.AssertFalse(ds_exists(queue_handle, ds_type_queue), "Queue destructor should destroy the ds_queue");
		return true;
	}, _queue_context);
	_queue_case.Timeout(55, "frames");
	_suite.AddCase(_queue_case);

	// TEST: Stack Destructor
	var _stack_case = new CrispyCaseAsync("test_destructors_stack_is_destroyed_after_delete");
	var _stack_context = {};
	_stack_context.state = undefined;
	_stack_context.subject = undefined;
	_stack_context.stack_handle = undefined;
	_stack_context.frames = 0;
	_stack_context.test_case = _stack_case;

	_stack_case.WaitBeginStep(function() {
		state = { stack_handle: undefined };
		subject = new destructors_test_stack_subject(state);
		stack_handle = state.stack_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _stack_context);

	_stack_case.WaitEndStep(function() {
		++frames;
		if (frames < 50)
		{
			return false;
		}

		test_case.AssertFalse(ds_exists(stack_handle, ds_type_stack), "Stack destructor should destroy the ds_stack");
		return true;
	}, _stack_context);
	_stack_case.Timeout(60, "frames");
	_suite.AddCase(_stack_case);

	// TEST: Buffer Destructor
	var _buffer_case = new CrispyCaseAsync("test_destructors_buffer_is_destroyed_after_delete");
	var _buffer_context = {};
	_buffer_context.state = undefined;
	_buffer_context.subject = undefined;
	_buffer_context.buffer_handle = undefined;
	_buffer_context.frames = 0;
	_buffer_context.test_case = _buffer_case;

	_buffer_case.WaitBeginStep(function() {
		state = { buffer_handle: undefined };
		subject = new destructors_test_buffer_subject(state);
		buffer_handle = state.buffer_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _buffer_context);

	_buffer_case.WaitEndStep(function() {
		++frames;
		if (frames < 55)
		{
			return false;
		}

		test_case.AssertFalse(buffer_exists(buffer_handle), "Buffer destructor should destroy the buffer");
		return true;
	}, _buffer_context);
	_buffer_case.Timeout(65, "frames");
	_suite.AddCase(_buffer_case);

	// TEST: Path Destructor
	var _path_case = new CrispyCaseAsync("test_destructors_path_is_destroyed_after_delete");
	var _path_context = {};
	_path_context.state = undefined;
	_path_context.subject = undefined;
	_path_context.path_handle = undefined;
	_path_context.frames = 0;
	_path_context.test_case = _path_case;

	_path_case.WaitBeginStep(function() {
		state = { path_handle: undefined };
		subject = new destructors_test_path_subject(state);
		path_handle = state.path_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _path_context);

	_path_case.WaitEndStep(function() {
		++frames;
		if (frames < 60)
		{
			return false;
		}

		test_case.AssertFalse(path_exists(path_handle), "Path destructor should destroy the path");
		return true;
	}, _path_context);
	_path_case.Timeout(70, "frames");
	_suite.AddCase(_path_case);

	// TEST: AnimCurve Destructor
	var _animcurve_case = new CrispyCaseAsync("test_destructors_animcurve_is_destroyed_after_delete");
	var _animcurve_context = {};
	_animcurve_context.state = undefined;
	_animcurve_context.subject = undefined;
	_animcurve_context.animcurve_handle = undefined;
	_animcurve_context.frames = 0;
	_animcurve_context.test_case = _animcurve_case;

	_animcurve_case.WaitBeginStep(function() {
		state = { animcurve_handle: undefined };
		subject = new destructors_test_animcurve_subject(state);
		animcurve_handle = state.animcurve_handle;
		delete subject;
		subject = undefined;
		return true;
	}, _animcurve_context);

	_animcurve_case.WaitEndStep(function() {
		++frames;
		if (frames < 65)
		{
			return false;
		}

		test_case.AssertFalse(animcurve_exists(animcurve_handle), "AnimCurve destructor should destroy the animcurve");
		return true;
	}, _animcurve_context);
	_animcurve_case.Timeout(75, "frames");
	_suite.AddCase(_animcurve_case);

	return _suite;
}

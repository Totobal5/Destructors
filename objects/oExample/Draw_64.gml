var _status = __destructors_test_runner.IsComplete() ? "Complete" : (__destructors_test_runner.IsRunning() ? "Running" : "Idle");

draw_text(10, 10, "Destructors Crispy Test Suite");
draw_text(10, 30, "Status: " + _status);
draw_text(10, 50, "Open the debug output to read the Crispy log.");
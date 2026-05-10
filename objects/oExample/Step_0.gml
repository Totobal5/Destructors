if (!__destructors_test_runner.IsComplete())
{
	__destructors_test_runner.Update();
}
else if (!__destructors_test_completed)
{
	__destructors_test_completed = true;
	show_debug_message("Destructors Crispy tests completed.");
}
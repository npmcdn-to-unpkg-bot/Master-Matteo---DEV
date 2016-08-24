//Runs as system on all referenced classes.
global class SchedulableDataAlignment implements Schedulable {
	//Global or public
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new DataAlignment());
	}
	
}
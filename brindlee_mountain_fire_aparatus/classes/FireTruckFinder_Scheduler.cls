/*
 * @description - Used to schedule batch of Matching products and Contact / Leads.
 * @createdBy   - Dreamwares 
 * @createdDate - 27-11-0215
 * @lastModifiedDate - 20/4/2016 
 */  
global class FireTruckFinder_Scheduler implements Schedulable {
    
    /*
    @description - Fetch products with required criterias and update their Add to Fire Truck Finder 
				   fields while adding them to the batch functionality.
     */ 
    public void execute( SchedulableContext sc ){
        Database.executeBatch( new FireTruckFinder_Batch(), 90 );
    }
    
    /*
    @description - Schedule Fire Truck Finder 10 run hourly everyday
     */
    public static void runSchedulerHourly(){
        FireTruckFinder_Scheduler schedule = new FireTruckFinder_Scheduler();
        String cron = '0 0 * * * ?';
        String jobID = system.schedule('Fire Truck Finder', cron, schedule);
        System.debug('jobID is:'+jobID);
    }
}
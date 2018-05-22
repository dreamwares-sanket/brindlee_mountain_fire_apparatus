/*
 * @description - Schedulable class for Truck Seller Segmentation Emails project which will update prospect
 *                fields and send emails to prospects depending on the posting date of product.
 * @createdBy   - Dreamwares
 * @createdDate - 19/1/2016
 */ 
global class SellerSegmentationScheduler implements Schedulable {
    
    global void execute( SchedulableContext sc ){
        SellerSegmentationBatch batch = new SellerSegmentationBatch();
        database.executeBatch( batch, 95);
    }
    
    /*
    @description - Schedule the class to run at specified hour. The hour value is fetched from custom settings.
     */ 
    global static void runSegmentationScheduler(){
        
        SellerSegmentationScheduler schedule = new SellerSegmentationScheduler();
        List< Scheduler_Settings__c > listSchedulerSettings;
        listSchedulerSettings = Scheduler_Settings__c.getAll().values();
        
        Integer schedule_Hour;
        if( listSchedulerSettings != null && !listSchedulerSettings.isEmpty() ){		// Fetch Custom settings to get the hour for which the class is scheduled
            schedule_Hour = Integer.ValueOf( listSchedulerSettings[0].Segmentation_Email_Schedule_Time__c );
        }
        
        // Assign defauly value to schedule hour
        if( schedule_Hour == null || schedule_Hour < 0 || schedule_Hour > 23 ){
			schedule_Hour = 20;
        }
        
        // Schedule class to run at specified hour of each day
        String cron = String.format('0 0 {0} * * ?', new List<String>{ String.valueOf( schedule_Hour ) });
        String schedulerName = 'Seller Segmentation Emails ' + System.now();
        String jobID = system.schedule( schedulerName, cron, schedule);
        System.debug('jobID is:'+jobID);
        
    } 
}
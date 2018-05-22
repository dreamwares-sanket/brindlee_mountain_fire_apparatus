/*
 * @description - Controller extension class for VF page AvailableTruckDetailView used to display
                  details of truck 
 * @dateCreated - 22/08/2015
 * @createdBy   - Dreamwares
 */
public with sharing class TestimonialsController{
    public transient List<Testimonial__c >listTestimonials{ get; set; }
    private PlatformCacheController cacheController = new PlatformCacheController();

    // Controller
    public TestimonialsController(){
    
    }
    
    public void initializeTestimonialsList() {
       listTestimonials = cacheController.getPlatformCahche('listTestimonials');//get list from platform cahce
       
       if( listTestimonials== null || listTestimonials.isEmpty() ){            
           try{
               listTestimonials = new List<Testimonial__c>([ SELECT Id, Review__c, Caption__c,
                                                                  ( SELECT Id, Main_Image__c, DragDropToCloud__Folder_Id__c,
                                                                           Amazon_S3_Image_URL__c
                                                                    FROM Cloud_Documents__r
                                                                    WHERE Show_Online__c = TRUE LIMIT 1)
                                                               FROM Testimonial__c 
                                                               ORDER BY CreatedDate DESC 
                                                               LIMIT 1000]);
                                                               
               cacheController.creaetPlatformCahche(listTestimonials, 'listTestimonials');
           }
           catch( Exception e){
               System.debug('Exception in fethcing testimonials ::: '+ e);
           }
       }
    }
}
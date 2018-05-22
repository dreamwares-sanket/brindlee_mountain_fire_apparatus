/*
 * @description - Test class for TestimonialsController 
 * @dateCreated - 10/09/2015
 * @createdBy   - Dreamwares
 */
@isTest
public class TestimonialsControllerTest {
	
    @testSetup
    public static void testSetup(){
        Testimonial__c objTestimonial;
        List<Testimonial__c> listTestimonial = new List< Testimonial__c>();
        for( integer i=0;i<5;i++ ){
            objTestimonial = new Testimonial__c();
            objTestimonial.Caption__c = 'Test Data';
            listTestimonial.add( objTestimonial );
        }
        insert listTestimonial;
        
        DragDropToCloud__Cloud_Documents__c objDoc;
		List< DragDropToCloud__Cloud_Documents__c > listDocs = new List< DragDropToCloud__Cloud_Documents__c >();
        
        //create cloud documents for Testinomials
        for( Testimonial__c testimonial : listTestimonial){
            objDoc = new DragDropToCloud__Cloud_Documents__c();
            objDoc.Testimonial_Image__c = testimonial.Id;
            objDoc.DragDropToCloud__Folder_Id__c = 'testFolder';
            objDoc.Name = 'CloudDoc_' + testimonial.name;
            listDocs.add(objDoc);
        }
        insert listDocs;
    }
    
    @isTest
    public static void testController(){
        TestimonialsController con = new TestimonialsController();
        con.initializeTestimonialsList();
        System.assertNotEquals(null, con.listTestimonials);
        System.assertNotEquals(null, con.listTestimonials);
        con.initializeTestimonialsList();

    }
}
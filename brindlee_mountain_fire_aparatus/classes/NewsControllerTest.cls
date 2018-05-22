/*
 * @description - Test class for NewsController used to display
                  details of news for page News
 * @dateCreated - 11/09/2015
 * @createdBy   - Dreamwares
 */
@isTest
public class NewsControllerTest {
    
    @testSetup
    public static void setuprecoprds(){
        List< In_The_News__c > listnews = new List< In_The_News__c >();
        In_The_News__c objNews;
        for( integer i=0;i<10;i++ ){
            objNews = new In_The_News__c();
            objNews.News__c = 'test News '+ i;
            listnews.add( objNews );
        }
        insert listnews;
    }
    
    @isTest
    public static void testNews(){
        NewsController con = new NewsController();
        con.initializeRecentNewsList();        
        System.assertNotEquals(null, con.listRecentNews);
    	con.initializeRecentNewsList();
    }
}
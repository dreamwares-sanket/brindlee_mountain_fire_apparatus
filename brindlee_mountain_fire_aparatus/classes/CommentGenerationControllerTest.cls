/*
 * This is a test class for vf page controller CommentGenerationController 
 * @created 2016/07/27
 * @author Dreamwares (Vidula)
 */
@isTest
public class CommentGenerationControllerTest {
  
    @isTest
    private static void testControllerMethods(){
        Comment_Generation__c newComment = new Comment_Generation__c();
        newComment.Include__c = true;
        newComment.Comment__c = 'Testing';
        newComment.Condition__c = 'Not Empty';
        newComment.Field_API_Name__c = 'Name';
        newComment.Field_Label__c = 'Name';

		insert newComment;        
        ApexPages.StandardController sc = new ApexPages.StandardController(newComment);
        
        CommentGenerationController controller = new CommentGenerationController(sc);        
        
        PageReference pageRef = Page.CommentGeneration;
        pageRef.getParameters().put('id', String.valueOf(newComment.Id));
        Test.setCurrentPage(pageRef);
        controller.saveComment();
        controller.saveAndNewComment();

    }

}
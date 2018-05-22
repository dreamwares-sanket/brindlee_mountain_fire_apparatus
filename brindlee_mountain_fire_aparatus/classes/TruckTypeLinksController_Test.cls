/*
 * Test class for code coverage of vf component controller TruckTypeLinksController
 * @createdDate 2016/10/14
 * @createdBy Dreamwares (Aditya S.)
 */ 
@isTest public class TruckTypeLinksController_Test {
	@isTest
    private static void testMethods(){
        TruckTypeLinksController controller = new TruckTypeLinksController();
        System.assert(!controller.getListCategoryWrappers().isEmpty());
    }
}
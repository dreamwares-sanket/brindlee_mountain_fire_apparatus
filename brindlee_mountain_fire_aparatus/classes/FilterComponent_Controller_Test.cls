/*
 * This is a test class for vf page controller HomepageController used on firetruckmall.com
 * @created 2016/07/20
 * @modifiedDate 2016/10/14
 * @author Dreamwares (Aditya S.)
 */
@isTest
public class FilterComponent_Controller_Test {
	
    @isTest
    private static void testControllerMethods(){
        FilterComponent_Controller controller = new FilterComponent_Controller();
        System.assert(!controller.getPriceOptions().isEmpty());
		System.assert(!controller.getYearOptions().isEmpty());
        System.assert(!controller.getChassisTypes().isEmpty());
        System.assert(!controller.getBrands().isEmpty());
        System.assert(!controller.getPumpSizeRanges().isEmpty());
        System.assert(!controller.getTankSizeRanges().isEmpty());
        System.assert(!controller.getCategories().isEmpty());
        System.assert(!controller.getMileageOptions().isEmpty());
        System.assert(!controller.getGeographicRegions().isEmpty());        
        System.assert(!controller.getWarrantyOptions().isEmpty());
        System.assertNotEquals( null, controller.redirectToAvailableTrucksPageWithUrlParams());
    }
}
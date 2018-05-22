/*
 * This is a test class for vf page controller HomepageController used on firetruckmall.com
 * @created 2016/07/20
 * @author Dreamwares (Aditya S.)
 */
@isTest
public class HomepageControllerTest {
	
    @isTest
    private static void testControllerMethods(){
        HomepageController controller = new HomepageController();
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
        System.assert(!controller.getListCategoryWrappers().isEmpty());
        System.assertNotEquals( null, controller.redirectToAvailableTrucksPageWithUrlParams());
    }
}
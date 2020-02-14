@isTest private class AutoForwardController_Test {
	static testmethod void testAutoForwardController(){

		Contact c = new Contact(lastname = 'test');
		insert c;
		PageReference p = Page.Auto_Forward;
		Contact testCont = [Select c.Id,c.Name from Contact c LIMIT 1];
		
		AutoForwardController afc = new AutoForwardController();
		ApexPages.currentPage().getParameters().clear();

		p = afc.ForwardOn();

		afc = new AutoForwardController();
	//	ApexPages.currentPage().getParameters().put('CF00NR0000000XiCd_lkid', testCont.Id);
		ApexPages.currentPage().getParameters().put('CF00N200000029p5q_lkid', testCont.Id);
		
		p = afc.ForwardOn();
        //System.assert(p.getUrl().indexOf('CF00NR0000000XiCd_lkid=' + testCont.id) > -1);
        System.assert(p.getUrl().indexOf('CF00N200000029p5q_lkid=' + testCont.id) > -1);
	}

}
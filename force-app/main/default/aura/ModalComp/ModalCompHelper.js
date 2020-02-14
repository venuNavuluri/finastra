/**
 *  @who    Gen Estrada <genalyn.estrada@weare4c.com>
 *  @when   24/07/2018
 *  @what   Controller for Lightning Component ModalComp
 *          Opens and closes the modal
 */
({
  /**
    *  Defines the header of the modal
    */
    initFunc: function(cmp) {
        var modalHeader = cmp.find('modalHeader');
        var status = cmp.get("v.status");
		var boldMessage = cmp.get("v.boldMessage");
		var className = '';

        if(status === 'Default'){
          className = " slds-theme_info";
        } else if(status === 'Warning'){
          className =  " slds-theme_warning";
        } else if(status === 'Error'){
          className =  " slds-theme_error";
          boldMessage = 'This page has an error. You might just need to refresh it. If the issue persists, please contact your Salesforce admin.';
        } else if(status === 'Success'){
          className =  " slds-theme_success";
        }

        cmp.set("v.boldMessage", boldMessage);
        $A.util.addClass(modalHeader, className);       
    },

	/**
	*  Opens modal
	*/
   openModalFunc: function(cmp) {
      cmp.set("v.isOpen", true);
   },
 
 	/**
	*  Closes modal
	*/
   closeModalFunc: function(cmp) {
       cmp.set("v.isOpen", false);
       var closeModalEvent = $A.get("e.c:CloseModal");
       closeModalEvent.setParams({"setModalView": false});
       closeModalEvent.fire();
   }
})
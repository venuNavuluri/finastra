/**
 *  @who    Gen Estrada <genalyn.estrada@weare4c.com>
 *  @when   24/07/2018
 *  @what   Controller for Lightning Component ModalComp
 *          Opens and closes the modal
 */
({
  /**
    * Initialisation 
    */
    doInit: function (cmp, event, helper) {
        helper.initFunc(cmp);
    },

    /**
    * Open modal 
    */
    openModal: function (cmp, event, helper) {
        helper.openModalFunc(cmp);
    },

    /**
    * Close modal 
    */
    closeModal : function(cmp, event, helper) {
    	helper.closeModalFunc(cmp);
    }
 
})
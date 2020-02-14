/**
 * @File Name          : CustomWrapper.cls
 * @Description        :
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 05/02/2020, 12:38:54
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2/4/2020   venu.navuluri@finastra.com     Initial Version
 **/
public with sharing class CustomWrapper {
  @TestVisible
  class InnerWrapper {
    @AuraEnabled
    public Integer Percentage { get; set; }
    @AuraEnabled
    public String Name { get; set; }
  }
  @AuraEnabled
  public List<InnerWrapper> itemList { get; set; }
}

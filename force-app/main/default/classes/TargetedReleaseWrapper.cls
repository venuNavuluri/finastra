public with sharing class TargetedReleaseWrapper {

  public Targeted_Release__c tr         {get; set;}
  public Boolean             selected   {get; set;}
  public Boolean             selectable {get; set;}  
  
  public TargetedReleaseWrapper(Targeted_Release__c tr) {
  	this.tr         = tr;
  	this.selected   = false;
    this.selectable = false;
  }

}
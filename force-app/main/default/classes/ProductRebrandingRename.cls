public class ProductRebrandingRename {
    
    public static void renameProductSet(String oldName,String newName){
        String newProdName='';
        List<Product_Set__c> productSetList =[SELECT Id,Name,Account__r.name,CreatedDate,PR_Old_Product_Set_Name__c,PR_Rename_Done__c
                                      FROM Product_Set__c WHERE Name LIKE :oldName AND PR_Rename_Done__c=false order by Account__r.name asc];
        system.debug('renameProductSet : No.of Product Set records -->>>>' + productSetList.size());                          
        For(Product_Set__c prod: productSetList){
            system.debug('Old Product Set Name is -->>>>' + prod.Name);
           
            prod.PR_Old_Product_Set_Name__c=prod.Name;
            newProdName= prod.Name.replace(oldName, newName);
            system.debug('New Product Set Name is -->>>>' + newProdName);
            prod.Name=newProdName;
            prod.PR_Rename_Done__c=true;
         }
          update productSetList;
   }
   
   public static void renameSupportEntitlement(String oldName,String newName,String newProductSetName){
        String newEntitlementName='';
        String oldNm='%'+oldName+'%';
        List<Entitlement__c> entitlementList =[SELECT Id,Name,CreatedDate,Account__r.name,Product_Set__r.name,PR_Old_Entitlement_Name__c,PR_Rename_Done__c FROM Entitlement__c WHERE name LIKE :oldNm AND Product_Set__r.name LIKE :newProductSetName AND PR_Rename_Done__c=false order by Account__r.name asc Limit 500];
        system.debug('renameSupportEntitlement : No.of Support Entitlements records -->>>>' + entitlementList.size());
        For(Entitlement__c obj: entitlementList){
            system.debug('Old Support Entitlement Name is -->>>>' + obj.Name);
          
            obj.PR_Old_Entitlement_Name__c=obj.Name;
            newEntitlementName= obj.Name.replace(oldName, newName);
            system.debug('New Support Entitlement Name is -->>>>' + newEntitlementName);
            if(newEntitlementName.length()>80){
                obj.Name=newEntitlementName.substring(0,80);
            }else{
            obj.Name=newEntitlementName;
            }
            obj.PR_Rename_Done__c=true;
          }
          update entitlementList;
   }
   
    public static void renameClientAsset(String oldName,String newName,String newProductSetName){
        String newClientAssetName='';
        String oldNm='%'+oldName+'%';
        List<Client_Asset__c> clientAssetList =[SELECT Id,Name,Product__r.name,Account__r.name,CreatedDate,Product_Set__r.name,PR_Old_Client_Asset_Name__c,PR_Rename_Done__c FROM Client_Asset__c Where name LIKE :oldNm AND PR_Rename_Done__c=false and Product__r.Product_Set__c!=Null and Product__r.Product_Set__c=:newProductSetName order by Account__r.name asc Limit 500];
        system.debug('renameClientAsset : No.of Client Assets records -->>>>' + clientAssetList.size());
        For(Client_Asset__c obj: clientAssetList){
            system.debug('Old Client Asset Name is -->>>>' + obj.Name);
           
            obj.PR_Old_Client_Asset_Name__c=obj.Name;
            newClientAssetName= obj.Name.replace(oldName, newName);
            system.debug('New Client Asset Name is -->>>>' + newClientAssetName);
            if(newClientAssetName.length()>80){
                obj.Name=newClientAssetName.substring(0,80);
            }else{
            obj.Name=newClientAssetName;
            }
            obj.PR_Rename_Done__c=true;
          }
          update clientAssetList;
   }
   
    public static void renameContractAsset(String oldName,String newName,String newProductSetName){
        String newContractAssetName='';
        String oldNm='%'+oldName+'%';
        List<Contract_Asset__c> contractAssetList =[SELECT Product__r.name,Account__r.name,CreatedDate,Id,Name,Product_Set__c,PR_Rename_Done__c,PR_Old_Contract_Asset_Name__c FROM Contract_Asset__c WHERE name LIKE :oldNm AND PR_Rename_Done__c=false and Product__r.Product_Set__c!=Null and Product__r.Product_Set__c=:newProductSetName  order by Account__r.name asc Limit 500];
        system.debug('renameContractAsset : No.of Contract Assets records fetched in one batch-->>>>' + contractAssetList.size());
            For(Contract_Asset__c obj: contractAssetList){
            system.debug('Old Contract Asset Name is -->>>>' + obj.Name);
            obj.PR_Old_Contract_Asset_Name__c=obj.Name;
            
            newContractAssetName= obj.Name.replace(oldName, newName);
            system.debug('New Contract Asset Name is -->>>>' + newContractAssetName);
             if(newContractAssetName.length()>80){
                obj.Name=newContractAssetName.substring(0,80);
            }else{
                obj.Name=newContractAssetName;
            }
            obj.PR_Rename_Done__c=true;
          }
          update contractAssetList;
     
   }
    
    public static void renameSalesOrderItem(String oldName,String newName,String newProductSetName){
        String newSalesOrderName='';
        String newSalesOrderDescription='';
        String oldNm='%'+oldName+'%';
        List<sales_order_item__c> salesOrderItemList =[select name, ID, description__c,PR_Old_Sales_Order_Item_Name__c,PR_Rename_Done__c from sales_order_item__c where ns_item__r.product_set__c=:newProductSetName AND PR_Rename_Done__c=false AND name LIKE :oldNm order by name asc limit 500];
        system.debug('renameSalesOrderItem : No.of Sales Order Item records fetched in one batch-->>>>' + salesOrderItemList.size());
            For(sales_order_item__c obj: salesOrderItemList){
            system.debug('Old sales order item Name is -->>>>' + obj.Name);
            obj.PR_Old_Sales_Order_Item_Name__c=obj.Name;
            obj.PR_Old_Description__c=obj.description__c;
            
            newSalesOrderName= obj.Name.replace(oldName, newName);
            system.debug('New sales order item name is -->>>>' + newSalesOrderName);
            if(obj.description__c != null){
                newSalesOrderDescription = obj.description__c.replace(oldName, newName);
            }
            system.debug('New sales order item description is -->>>>' + newSalesOrderDescription);
            
            if(newSalesOrderName.length()>80){
                obj.Name=newSalesOrderName.substring(0,80);
            }else{
                obj.Name=newSalesOrderName;
            }
            obj.description__c=newSalesOrderDescription;
            obj.PR_Rename_Done__c=true;
          }
          update salesOrderItemList;
     
   }
}
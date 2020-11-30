CREATE proc [dbo].[p_CO_InsUpdSAPGR]  
@pIdContrato int,  
@pPO_SAPNumber varchar(50),  
@pPOLineNumber varchar(50),  
@pQuantity float,  
@pUnitPrice float,  
@pMoneda varchar(50),  
@pImporte float,  
@pAccountAssignment varchar(50),  
@pCostObject varchar(50),  
@pMaterialGroup varchar(50),  
@pMaterialGroupDesc2 varchar(50),  
@pMaterialNumber varchar(50),  
@pMaterialDescShort varchar(150),  
@pCreadoPor int,  
@pUOM varchar(50),  
@pMatDocN varchar(15),  
@pMatDocItem varchar(15),  
@pDocumentDate varchar(15),  
@pDocPostingDate varchar(15),  
@pPlant varchar(15),  
@pGRReferenceNumber varchar(20),  
@pEsNuevo bit out  
as  
  
  
 set @pPO_SAPNumber = rtrim(ltrim(@pPO_SAPNumber))  
 set @pPOLineNumber = ltrim(rtrim(@pPOLineNumber))  
 set @pDocumentDate = ltrim(rtrim(@pDocumentDate))  
  
 set @pEsNuevo = 0  
 if not exists (  
  select 1  
  from [CO_SAPGR]  
  where PO_SAPNumber = @pPO_SAPNumber and  
  PO_SAPNumber = @pPO_SAPNumber and  
  POLineNumber = @pPOLineNumber and  
  DocumentDate = @pDocumentDate  
 )  
 begin  
    
  insert into [dbo].[CO_SAPGR](  
   IdContrato,PO_SAPNumber,POLineNumber,Quantity,  
   UnitPrice,Moneda,Importe,AccountAssignment,  
   CostObject,MaterialGroup,MaterialGroupDesc2,MaterialNumber,  
   MaterialDescShort,CreadoEl,CreadoPor,UOM,Plant,  
   MatDocN,  MatDocItem,  DocumentDate, DocPostingDate,  
   GRReferenceNumber  
  )  
  values(  
   @pIdContrato,@pPO_SAPNumber,@pPOLineNumber,@pQuantity,  
   @pUnitPrice,@pMoneda,@pImporte,@pAccountAssignment,  
   @pCostObject,@pMaterialGroup,@pMaterialGroupDesc2,@pMaterialNumber,  
   @pMaterialDescShort,getdate(),@pCreadoPor,@pUOM,@pPlant,  
   @pMatDocN,  @pMatDocItem,  @pDocumentDate, @pDocPostingDate,  
   @pGRReferenceNumber  
  )  
  
  set @pEsNuevo = 1  
 end  
 Else  
 Begin  
  update [CO_SAPGR]  
  set Quantity = @pQuantity,  
  UnitPrice = @pUnitPrice,  
  Moneda = @pMoneda,  
  Importe = @pImporte,  
  AccountAssignment = @pAccountAssignment,  
  CostObject = @pCostObject,  
  MaterialGroup = @pMaterialGroup,  
  MaterialGroupDesc2 = @pMaterialGroupDesc2,  
  MaterialNumber = @pMaterialNumber,  
  MaterialDescShort = @pMaterialDescShort,  
  UOM = @pUOM,  
  Plant = @pPlant,  
  GRReferenceNumber = case when isnull(GRReferenceNumber,'')='' then  @pGRReferenceNumber else GRReferenceNumber end,  
  MatDocN = @pMatDocN,    
  MatDocItem = @pMatDocItem,    
  DocumentDate = @pDocumentDate,   
  DocPostingDate = @pDocPostingDate  
  where PO_SAPNumber = @pPO_SAPNumber and  
  PO_SAPNumber = @pPO_SAPNumber and  
  POLineNumber = @pPOLineNumber and  
  DocumentDate = @pDocumentDate  
 end  
  
  
 exec p_COSAP_RecalcularContrato  
  
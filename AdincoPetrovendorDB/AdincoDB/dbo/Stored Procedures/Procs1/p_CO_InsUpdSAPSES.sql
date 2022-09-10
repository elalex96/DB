--==============================================================
-- Modificador: Neri del Angel
-- Fecha:		08 de Septiembre del 2022
-- Ajuste:		Se agrega el SESReferenceNumber dentro de la 
--				validación de not exists para que agregue nuevo 
--				registro si este no coincide con uno agregado
--==============================================================
CREATE proc [dbo].[p_CO_InsUpdSAPSES]
    @pIdContrato int,
    @pSESNumber varchar(50),
    @pSESLine varchar(50),
    @pPO_SAPNumer varchar(50),
    @pPOLineNumber varchar(50),
    @pQuantity float,
    @pUnitPrice float,
    @pCurrency varchar(50),
    @pImporte float,
    @pAccountAssignment varchar(50),
    @pCostObject varchar(50),
    @pMaterialGroup varchar(50),
    @pMaterialGroupDesc2 varchar(150),
    @pCreadoPor int,
    @pUOM varchar(50),
    --  
    @pSESPostingDate varchar(15),
    @pSESServiceStart varchar(15),
    @pSESServiceEnd varchar(15),
    @pPlant varchar(15),
    @pSESReferenceNumber varchar(20),
    @pEsNuevo bit out
as
set @pEsNuevo = 0
set @pSESNumber = ltrim(rtrim(@pSESNumber))
set @pSESLine = ltrim(rtrim(@pSESLine))
set @pPO_SAPNumer = ltrim(rtrim(@pPO_SAPNumer))
set @pPOLineNumber = ltrim(rtrim(@pPOLineNumber))
if not exists
(
    select 1
    from [CO_SAPSES]
    where IdContrato = @pIdContrato
          and SESNumber = @pSESNumber
          and SESLine = @pSESLine
          and PO_SAPNumer = @pPO_SAPNumer
          and POLineNumber = @pPOLineNumber
		  and SESReferenceNumber = @pSESReferenceNumber
)
begin

    insert into [dbo].[CO_SAPSES]
    (
        IdContrato,
        SESNumber,
        SESLine,
        PO_SAPNumer,
        POLineNumber,
        Quantity,
        UnitPrice,
        Currency,
        Importe,
        AccountAssignment,
        CostObject,
        MaterialGroup,
        MaterialGroupDesc2,
        CreadoEl,
        CreadoPor,
        UOM,
        --  
        SESPostingDate,
        SESServiceStart,
        SESServiceEnd,
        Plant,
        --  
        SESReferenceNumber
    )
    values
    (   @pIdContrato,
        @pSESNumber,
        @pSESLine,
        @pPO_SAPNumer,
        @pPOLineNumber,
        @pQuantity,
        @pUnitPrice,
        @pCurrency,
        @pImporte,
        @pAccountAssignment,
        @pCostObject,
        @pMaterialGroup,
        @pMaterialGroupDesc2,
        getdate(),
        @pCreadoPor,
        @pUOM,
        --  
        @pSESPostingDate,
        @pSESServiceStart,
        @pSESServiceEnd,
        @pPlant,
        --  
        @pSESReferenceNumber
    )

    set @pEsNuevo = 1

end
Else
Begin
    update [CO_SAPSES]
    set Quantity = @pQuantity,
        UnitPrice = @pUnitPrice,
        Currency = @pCurrency,
        Importe = @pImporte,
        AccountAssignment = @pAccountAssignment,
        CostObject = @pCostObject,
        MaterialGroup = @pMaterialGroup,
        MaterialGroupDesc2 = @pMaterialGroupDesc2,
        CreadoPor = @pCreadoPor,
        UOM = @pUOM,
        SESPostingDate = @pSESPostingDate,
        SESServiceStart = @pSESServiceStart,
        SESServiceEnd = @pSESServiceEnd,
        Plant = @pPlant,
        SESReferenceNumber = case
                                 when isnull(SESReferenceNumber, '') = '' then
                                     @pSESReferenceNumber
                                 else
                                     SESReferenceNumber
                             end
    where IdContrato = @pIdContrato
          and SESNumber = @pSESNumber
          and SESLine = @pSESLine
          and PO_SAPNumer = @pPO_SAPNumer
          and POLineNumber = @pPOLineNumber
		  and SESReferenceNumber = @pSESReferenceNumber
End

exec p_COSAP_RecalcularContrato
USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_WDEA_AD_BitacoraPurchasingImportadosWDEA_ADINCO_SAP]    Script Date: 27/10/2022 09:56:40 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 27/10/2022
-- Description:	consulta de datos procesados en WDEA ADINCO-SAP
-- =============================================
CREATE PROCEDURE [dbo].[SP_WDEA_AD_BitacoraPurchasingImportadosWDEA_ADINCO_SAP]
	-- Add the parameters for the stored procedure here
	@FechaInicio DATETIME,
	@FechaFin DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		[IDIMPORTACION]
      ,[IDLAYOUT]
      ,[ITEM]
      ,[PURCHASE_ORGANIZATION]
      ,[IDCONTRATO]
      ,[COST_CENTER]
      ,[WBS_ELEMENT]
      ,[IDLINEAPRESUPUESTOMES]
      ,[OUTLINE_AGREEMENT]
      ,[SHORT_TEXT]
      ,[IDMATERIAL]
      ,[VALIDITY_PER_START]
      ,[VALIDITY_PER_END]
      ,[DELETION_INDICATOR]
      ,[PLANT]
      ,[ORDER_QUANTITY]
      ,[ORDER_UNIT]
      ,[IDUNIDAD]
      ,[NET_PRICE]
      ,[CURRENCY]
      ,[IDMONEDA]
      ,[VENDOR_SUPPLIYING_PLANT]
      ,[IDPROVEEDOR]
      ,[PURCHASING_DOCUMENT]
      ,[RELEASE_STATE]
      ,[NAME_OF_VENDOR]
      ,[ORDER_PRICE_UNIT]
      ,[NET_ORDER_VALUE]
      ,[REQUISITIONER]
      ,[IDUSUARIOSOLICITANTE]
      ,[TERMINOS_DE_PAGO]
      ,[JUSTIFICACION]
      ,[IdBitacora]
      ,[IdPedidoADINCO]
      ,[MECANISMO_CONTRATACION]
	FROM WDEA_PurchasingDocumentsImportados (NOLOCK)
	WHERE VALIDITY_PER_START BETWEEN @FechaInicio AND @FechaFin

END

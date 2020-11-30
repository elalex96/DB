-- =============================================
-- Author:		Miguel Gomez
-- Create date: 21-09-2018
-- Description:	Crea aceptacion de servicio basado en SES o GR
-- =============================================
CREATE procedure [dbo].[sp_MPY_SESGRtoAceptacionDetalle]
--sp_MPY_SESGRtoAceptacion 1,1000002094, 1 , 1
	-- Add the parameters for the stored procedure here
	@SESGR int = 0, 
	@IdSESGR nvarchar(MAX),
	@IdAceptacion int,
	@IdUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF @SESGR = 1 
	BEGIN
INSERT INTO [dbo].[MPY_MM_AceptacionPedidoDetalle]
           ([IdAceptacionPedido]
           ,[Cantidad]
           ,[Detalle]
           ,[CreadoPor]
           ,[Creado]
           ,[PrecioUnitario]
           ,[IdMoneda]
           ,[Unidad]

        
           ,[SAPNumber]
           ,[Partida]
           ,[DescripcionCorta]
           ,[DescripcionLarga])

   select @IdAceptacion as [IdAceptacionPedido],Quantity, MaterialGroupDesc2 , 
		   @IdUsuario as IdUsuario, CURRENT_TIMESTAMP,  UnitPrice, Currency, UOM, 'SAPNumber' as SAPNumber, SESLine, MaterialGroupDesc2, MaterialGroupDesc2 from adinco..CO_SAPSES where SESNumber = @IdSESGR
	END
	ELSE 
	BEGIN
	INSERT INTO [dbo].[MPY_MM_AceptacionPedidoDetalle]
           ([IdAceptacionPedido]
           ,[Cantidad]
           ,[Detalle]
           ,[CreadoPor]
           ,[Creado]
           ,[PrecioUnitario]
           ,[IdMoneda]
           ,[Unidad]

        
           ,[SAPNumber]
           ,[Partida]
           ,[DescripcionCorta]
           ,[DescripcionLarga])

   select @IdAceptacion as [IdAceptacionPedido],Quantity, MaterialGroupDesc2 , 
		   @IdUsuario as IdUsuario, CURRENT_TIMESTAMP,  UnitPrice, Moneda, UOM, 'SAPNumber' as SAPNumber, polinenumber, MaterialGroupDesc2, MaterialGroupDesc2 from adinco..CO_SAPGR where [PO_SAPNumber] = @IdSESGR
	END
END

-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	Detalle de materiales que fueron aceptado en la aceptación de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_AceptacionPedimentoComprobanteDetalle_Petrovendor]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdPedimentoComprobante INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME,
    @TipoDetalle NVARCHAR(50),
	@IdDocFacturaActivo INT 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF 2 = @IdDocFacturaActivo   --_PedimentoImportacion UTL CV_TipoDoc ADINCO - PETROVENDOR 
	BEGIN 
		SELECT PCD.IdPedimentoComprobanteDetalle,
			   PCD.IdUnidadMedida,         
			   PCD.DescripcionMercancia,
			   PCD.PrecioUnitario,
			   PCD.Cantidad,		  
			   PCD.ImporteTotal,
			   PCD.NumeroSerieMercancia
		FROM dbo.FI_PedimentoComprobanteDetalle PCD
			LEFT JOIN dbo.FI_PedimentoComprobante PC
				ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
			LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APPC ON APPC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
			LEFT JOIN dbo.MM_AceptacionPedido AP
				ON AP.IdAceptacionPedido = APPC.IdAceptacionPedido
			LEFT JOIN MM_Pedido P ON P.IdPedido=AP.IdPedido
		WHERE  PCD.IdPedimentoComprobante = @IdPedimentoComprobante AND P.IdSubcontratista=@IdProveedor
	END 

	IF 3 = @IdDocFacturaActivo --_ComprobanteExtranjero UTL CV_TipoDoc ADINCO - PETROVENDOR 
	BEGIN 
		SELECT PCD.IdPedimentoComprobanteDetalle,
			   PCD.IdUnidadMedida,         
			   PCD.DescripcionMercancia,
			   PCD.PrecioUnitario,
			   PCD.Cantidad,		  
			   PCD.ImporteTotal,
			   PCD.NumeroSerieMercancia
		FROM dbo.FI_PedimentoComprobanteDetalle PCD
			LEFT JOIN dbo.FI_PedimentoComprobante PC
				ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
			LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APPC ON APPC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
			LEFT JOIN dbo.MM_AceptacionPedido AP
				ON AP.IdAceptacionPedido = APPC.IdAceptacionPedido
			LEFT JOIN MM_Pedido P ON P.IdPedido=AP.IdPedido
		WHERE  PCD.IdPedimentoComprobante = @IdPedimentoComprobante AND P.IdSubcontratista=@IdProveedor
	END 

END;



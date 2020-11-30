-- =============================================
-- Author:   Daniel AC
-- Create date: 01/10/2019
-- Description:  Obtener el contrato de una de las facturas relacionadas al complemento de pago
-- =============================================

CREATE procedure [dbo].[SP_DetalleContratoSeguimientoPago]
@IdFacturaRelacionada INT
AS
BEGIN
	 

	DECLARE @IdContrato INT = (SELECT TOP 1
									SP.IdContrato
								FROM dbo.MM_AceptacionFactura AS AF
								LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
								LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
								LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
								WHERE AF.IdFactura = @IdFacturaRelacionada);

	DECLARE @IDCONTRATOMPY INT = (SELECT TOP 1
										CO.IdContrato
									FROM dbo.MPY_MM_AceptacionFactura AS AF
									LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
									LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE Modern_Spanish_CI_AS = AP.IdPedido COLLATE Modern_Spanish_CI_AS
									LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PC ON PC.Planta = PO.Plant
									LEFT JOIN Adinco.dbo.CO_Contrato AS CO ON CO.IdContratista = PC.IdContratista
									WHERE AF.IdFactura = @IdFacturaRelacionada
									GROUP BY CO.IdContrato)


	SELECT ISNULL(@IdContrato,@IDCONTRATOMPY)
END 
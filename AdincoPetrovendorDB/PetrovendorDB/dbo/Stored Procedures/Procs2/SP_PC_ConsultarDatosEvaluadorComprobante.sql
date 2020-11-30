-- =============================================
-- Author:		DANIEL AC 
-- Create date: 18/04/2018
-- Description:	CONSULTAR DE INFORMACIÓN DE PERSONA QUE REALIZARA EVALUACIÓN AL PROVEEDOR
-- =============================================

CREATE  PROCEDURE [dbo].[SP_PC_ConsultarDatosEvaluadorComprobante]
	@IdOperacion INT,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	
AS
BEGIN	
	SELECT U.Correo, u.IdUsuario, AP.IdProveedor
	FROM dbo.FI_PedimentoComprobante AF
	INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APPC ON APPC.IdPedimentoComprobante=AF.IdPedimentoComprobante
	INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido = APPC.IdAceptacionPedido
	INNER JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
	INNER JOIN dbo.TA_Operacion TAO ON TAO.IdDocumento = AF.IdPedimentoComprobante
	INNER JOIN dbo.S_Usuario U ON U.IdUsuario = P.CreadoPor	
	WHERE  TAO.IdOperacion =@IdOperacion
END



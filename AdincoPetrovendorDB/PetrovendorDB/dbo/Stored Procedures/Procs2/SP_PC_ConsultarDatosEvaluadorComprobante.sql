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
	JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APPC 
		ON AF.IdPedimentoComprobante = APPC.IdPedimentoComprobante
	JOIN dbo.MM_AceptacionPedido AP 
		ON APPC.IdAceptacionPedido = AP.IdAceptacionPedido 
	JOIN dbo.MM_Pedido P 
		ON AP.IdPedido = P.IdPedido 
	JOIN dbo.TA_Operacion TAO 
		ON AF.IdPedimentoComprobante = TAO.IdDocumento 
		AND IdTipoOperacion= 16 --> CTE Aprobación Pedimento/Comprobante Extranjero
	JOIN dbo.S_Usuario U 
		ON  P.CreadoPor	 = U.IdUsuario 
	WHERE  TAO.IdOperacion =@IdOperacion
	AND U.Activo=1 --> CTE Debe estar activo
	GROUP BY U.Correo, u.IdUsuario, AP.IdProveedor

END



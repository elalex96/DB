USE [Petrovendor]
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ConsultarDatosEvaluador'
)
    DROP PROCEDURE SP_ConsultarDatosEvaluador;
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultarDatosEvaluador]    Script Date: 06/10/2022 03:16:03 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ConsultarDatosEvaluador]	@IdOperacion INT,	    @IdContrato    INT = null,    @IdUsuario     INT = null,    @FechaRegistro DATETIME = null	ASBEGIN		SELECT U.Correo, u.IdUsuario, AP.IdProveedor	FROM dbo.MM_AceptacionFactura AF	JOIN dbo.MM_AceptacionPedido AP 		ON  AF.IdAceptacionPedido =AP.IdAceptacionPedido	JOIN dbo.MM_Pedido P 		ON AP.IdPedido = P.IdPedido 	JOIN dbo.TA_Operacion TAO 		ON AF.IdAceptacionFactura = TAO.IdDocumento 		AND IdTipoOperacion= 10 --> CTE Aprobación Factura 	JOIN dbo.S_Usuario U 		ON  P.CreadoPor	 = U.IdUsuario 	WHERE  TAO.IdOperacion = @IdOperacion	AND U.Activo =1 --> CTE Debe estar activo	GROUP BY U.Correo, u.IdUsuario, AP.IdProveedorEND
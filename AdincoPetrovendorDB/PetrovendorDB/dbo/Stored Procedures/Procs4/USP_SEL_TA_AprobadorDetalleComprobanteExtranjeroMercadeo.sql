USE [Petrovendor]
GO
DROP PROC IF EXISTS [USP_SEL_TA_AprobadorDetalleComprobanteExtranjeroMercadeo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <28-01-2026>
-- Description:	<Consulta usuarios con rol de aprobación de comprobante extranjero mercadeo>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_TA_AprobadorDetalleComprobanteExtranjeroMercadeo] 
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido INT,
@IdTarea INT,
@IdOperacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Contrato NVARCHAR(500) 

	SELECT @Contrato = CONCAT(ISNULL(C.NumeroContrato,'-'),'-',ISNULL(AC.NombreAreaContractual,'-'))
	FROM MM_AceptacionPedido AP
	JOIN MM_Pedido P
		ON AP.IdPedido = P.IdPedido			
	LEFT JOIN Adinco..CO_Contrato C
		ON P.IdContrato = C.IdContrato
	LEFT JOIN Adinco..CO_AreaContractual AC
		ON C.IdAreaContractual = AC.IdAreaContractual
	WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
	GROUP BY C.NumeroContrato, AC.NombreAreaContractual

	SELECT DISTINCT		
		IdAprobador = US.IdUsuario,		
		NombreAprobador = US.Nombre,
		CorreoAprobador = US.Correo,
		T.NoSecuencia,
	    NombreTipoOperacion = TTO.NombreOperacion,
		NombreContrato = ISNULL(@Contrato,'-')
	FROM TA_Tarea AS T (NOLOCK) 
		JOIN TA_Operacion AS TOO
			ON T.IdOperacion = TOO.IdOperacion	
		JOIN S_Usuario (NOLOCK) AS US
			ON T.IdAprobador = US.IdUsuario
		JOIN TA_TipoOperacion (NOLOCK) AS TTO
			ON TOO.IdTipoOperacion = TTO.IdTipoOperacion		
	WHERE T.IdOperacion = @IdOperacion
		  AND T.IdTarea = @IdTarea
	ORDER BY T.NoSecuencia ASC;
	
END

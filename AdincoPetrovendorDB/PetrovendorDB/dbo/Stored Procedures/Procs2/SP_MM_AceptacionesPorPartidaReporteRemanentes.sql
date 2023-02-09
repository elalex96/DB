USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_AceptacionesPorPartidaReporteRemanentes'
)
    DROP PROCEDURE SP_MM_AceptacionesPorPartidaReporteRemanentes;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/01/2023
-- Description:	consulta de las aceptaciones por material del reporte de remanentes
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AceptacionesPorPartidaReporteRemanentes]
	-- Add the parameters for the stored procedure here
	@IdPedidoDetalle INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		APD.IdAceptacionPedido,
		APD.Cantidad AS CantidadAceptada,
		CAST(APD.Creado AS DATE) AS FechaAceptacion,
		AP.Comentario
	FROM MM_Pedido AS P 
		JOIN MM_PedidoDetalle AS PD
			ON P.IdPedido = PD.IdPedido
			AND PD.IdPedidoDetalle = @IdPedidoDetalle
		JOIN MM_PeticionOfertaDetalle AS POF
			ON PD.IdPeticionOfertaDetalle = POF.IdPeticionOfertaDetalle
		JOIN MM_AceptacionPedidoDetalle AS APD	
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
		JOIN MM_AceptacionPedido AS AP
			ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
			AND ISNULL(AP.Activo,0) = 1
			AND ISNULL(AP.IdEliminado,0) = 0;
END

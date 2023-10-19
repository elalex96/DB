USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MM_ConsultaSolicitudPedidoReciclaje
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- 05-09-2023 Se retornar el IdLocalidad y Solicitante 
-- =============================================
-- Author:		Luis David
-- Create date: 05/10/2023
-- Description:	Petrovendor/2522 - Se obtiene la localidad de solped reciclada
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedidoReciclaje]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT, 
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	SP.IdPeriodo,
	SP.IdPresupuesto,
	SP.MotivoUrgencia,
	SP.IdPrioridadSolicitudPedido,
	SP.IdTipoSolicitudPedido,
	SP.VisitaRequerida,
	SP.JuntaAclaracionesRequerida,
	SP.FechaEntregaRequerida,
	SP.UnicoDomicilioEntrega,
	SP.IdContrato,
	SP.AdjudicableParcialmente,
	SP.UnaSolaEntregaRequerida,
	SP.EntregasParciales,
	ISNULL(SP.FechaEntregaFinRequerida, GETDATE()) AS FechaEntregaFinRequerida,
	ISNULL(SP.IdDomicilioEntrega,0),
	SP.IdSolicitudPedido,
	ISNULL(SP.IdLocalidad,0) AS IdLocalidad,
	ISNULL(SP.Solicitante,0) AS Solicitante,
	L.Nombre AS 'Localidad'
	FROM MM_SolicitudPedido AS SP (NOLOCK)
	LEFT JOIN MM_Localidades L (NOLOCK) ON
	SP.IdLocalidad = L.Id
	WHERE SP.IdSolicitudPedido=@IdSolicitudPedido
END

USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultaSolicitudPedidoReciclaje'
)
    DROP PROCEDURE SP_MM_ConsultaSolicitudPedidoReciclaje;
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaSolicitudPedidoReciclaje]    Script Date: 05/09/2023 11:51:02 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- 05-09-2023 Se retornar el IdLocalidad y Solicitante 
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
	ISNULL(SP.Solicitante,0) AS Solicitante
	FROM MM_SolicitudPedido AS SP (NOLOCK)
	WHERE SP.IdSolicitudPedido=@IdSolicitudPedido

END
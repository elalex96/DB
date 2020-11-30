-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedido]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido int 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT SP.IdSolicitudPedido,
	 SP.MotivoUrgencia,
	 TSP.TipoSolicitudPedido, 
	 SP.FechaAlta,
	 SP.AdjudicableParcialmente,
	 SP.VisitaRequerida,
	 SP.JuntaAclaracionesRequerida, 
	 SP.UnaSolaEntregaRequerida, 
	 SP.FechaEntregaRequerida,
	 SP.FechaEntregaFinRequerida, 
	 TE.Nombre,PSP.Prioridad, 
	 TAO.IdEstatusOperacion, 
	 U.Nombre, 
	 TAO.IdOperacion, 
	 ISNULL(SP.PeticionEnviada, 'false') AS PeticionEnviada,
	 TiOp.NombreOperacion,
	 CC.CentroCosto,
	 ISNULL(TC.Termino,'No aplica') as Termino,
	 SP.IdContrato,
	 SP.IdPeriodo,
	 SP.IdPresupuesto,
	 SP.IdLineaPresupuesto,
	 TG.TipoGasto,
	 ISNULL(SP.Fianza,'false'),
	 ISNULL(SP.Controlados,'false'),
	 SP.UnicoDomicilioEntrega,
	 SP.EntregasParciales
	FROM MM_SolicitudPedido AS SP
	INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido
	INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido 
	INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion 
	INNER JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
	INNER JOIN S_Usuario AS U ON U.IdUsuario=TAO.IdAsignador
	INNER JOIN TA_TipoOperacion AS TiOp ON TiOp.IdTipoOperacion = TAO.IdTipoOperacion
	INNER JOIN CC_CentroCosto AS CC ON CC.IdCentroCosto = SP.IdCentroCosto
	LEFT JOIN MM_TerminoComercio AS TC ON TC.IdTerminoComercio = SP.IdTerminoInternacionales
	LEFT JOIN MM_TipoGastos AS TG ON TG.IdTipoGasto = SP.IdTipoGasto
	WHERE TAO.IdTipoOperacion=2 AND  SP.IdSolicitudPedido=@IdSolicitudPedido

END


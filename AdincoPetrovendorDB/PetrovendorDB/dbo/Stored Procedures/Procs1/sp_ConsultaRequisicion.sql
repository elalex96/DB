-- =============================================
-- Author:		Alexander G
-- Create date: 27-06-17
-- Description:	Consultar Detalles de flujo tarea especifico 
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultaRequisicion]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT 
	SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.IdEstado, SP.FechaEntregaRequerida, TG.TipoGasto, SP.IdPresupuesto
	 FROM MM_SolicitudPedido AS SP
	 INNER JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
	 INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
	 INNER JOIN MM_TipoGastos AS TG ON TG.IdTipoGasto = SP.IdTipoGasto
	 --INNER JOIN TA_Estatus AS E ON E.IdEstatus = SP.IdEstado
	 --INNER JOIN DG_Domicilio AS D ON D.IdDomicilio = SP.IdDomicilioEntrega
	 --INNER JOIN MM_Material AS M ON M.IdMaterial = SPD.IdMaterial
	 WHERE SP.IdSolicitudPedido = @IdSolicitudPedido

END


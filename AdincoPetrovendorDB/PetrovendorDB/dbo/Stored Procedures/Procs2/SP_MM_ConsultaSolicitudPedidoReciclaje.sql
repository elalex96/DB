-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudPedidoReciclaje]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT, 
	 
	 /*--------------------
    parametros contrato
  --------------------*/
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME
  /*--------------------
  --------------------*/
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
	SP.IdSolicitudPedido

	 --SP.FechaAlta,
	 --TE.Nombre,PSP.Prioridad, 
	 --TAO.IdEstatusOperacion, 
	 --U.Nombre, 
	 --TAO.IdOperacion, 
	 --ISNULL(SP.PeticionEnviada, 'false') AS PeticionEnviada,
	 --TiOp.NombreOperacion,
	 --CC.CentroCosto,
	 --ISNULL(TC.Termino,'No aplica') as Termino,
	 --SP.IdLineaPresupuesto,
	 --TG.TipoGasto,
	 --ISNULL(SP.Fianza,'false'),
	 --ISNULL(SP.Controlados,'false'),
	FROM MM_SolicitudPedido AS SP (NOLOCK)
	WHERE SP.IdSolicitudPedido=@IdSolicitudPedido

END
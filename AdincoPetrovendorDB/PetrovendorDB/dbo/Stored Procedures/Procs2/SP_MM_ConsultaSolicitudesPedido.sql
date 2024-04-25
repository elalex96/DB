use Petrovendor
go
drop proc if exists SP_MM_ConsultaSolicitudesPedido
go
-- =============================================
-- Author:		<Luis David>
-- Create date: <02/24/2024>
-- Description:	<Se agrega el filtro por @FechaInicio y @FechaFin, Petrovendor #2737>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudesPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int,
	@Estatus int,
	@IdTipoUsuario INT,	
    @IdContrato    INT = null,
    @FechaRegistro DATETIME = null,
	@FechaInicio datetime,
	@FechaFin datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;	
  
  -- TipoOperacion --> 2 = Solicitud de Pedido
  IF(@Estatus = 0)
  BEGIN
	SELECT 
		SP.IdSolicitudPedido, 
		SP.MotivoUrgencia,
		TSP.TipoSolicitudPedido, 
		SP.FechaAlta,		
		TE.Nombre AS Nombre,
		CC.CentroCosto,
		U.Nombre AS NombreUsuario,
		TAO.Descripcion,
		AC.NombreAreaContractual AS AreaContractual	,
		PR.ID_PR,
		Contrato = c.NumeroContrato,
		ISNULL(LC.Nombre,'') AS Localidad
	FROM MM_SolicitudPedido AS SP (NOLOCK)
		INNER JOIN MM_TipoSolicitudPedido AS TSP  (NOLOCK)
			ON SP.IdTipoSolicitudPedido  = TSP.IdTipoSolicitudPedido
		INNER JOIN TA_Operacion AS TAO  (NOLOCK)
			ON SP.IdSolicitudPedido   = TAO.IdDocumento 
		INNER JOIN TA_Estatus AS TE  (NOLOCK)
			ON TAO.IdEstatusOperacion  = TE.IdEstatus  
		LEFT JOIN CC_CentroCosto AS CC  (NOLOCK)
			ON SP.IdCentroCosto = CC.IdCentroCosto
		INNER JOIN S_Usuario AS U  (NOLOCK)
			ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK)
			ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
			ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.DEA_AdjuntoPR PR  (NOLOCK)
			ON SP.IdSolicitudPedido = PR.IdSolicitudPedido
		LEFT JOIN MM_Localidades LC (NOLOCK)
			ON SP.IdLocalidad = LC.Id
	WHERE (SP.IdUsuarioSolicitante = @IdUsuario or @IdTipoUsuario NOT IN (9))
		AND SP.IdProveedor = @IdProveedor 
		AND ISNULL(TAO.IdTipoOperacion, 2)=2 
		AND ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)<>1
		AND (ISNULL(TE.IdEstatus,9) = @Estatus OR @Estatus = 0)
		AND CAST(SP.FechaAlta AS date) BETWEEN CAST(@FechaInicio AS date) AND CAST(@FechaFin AS date)
	ORDER BY SP.FechaAlta DESC     
  END
  ELSE
  BEGIN
	SELECT 
		SP.IdSolicitudPedido, 
		SP.MotivoUrgencia,
		TSP.TipoSolicitudPedido, 
		SP.FechaAlta,		
		TE.Nombre AS Nombre,
		CC.CentroCosto,
		U.Nombre AS NombreUsuario,
		TAO.Descripcion,
		AC.NombreAreaContractual AS AreaContractual,
		PR.ID_PR,
		Contrato = c.NumeroContrato,
		ISNULL(LC.Nombre,'') AS Localidad
	FROM MM_SolicitudPedido AS SP 
		JOIN MM_TipoSolicitudPedido AS TSP  (NOLOCK)
		ON SP.IdTipoSolicitudPedido  = TSP.IdTipoSolicitudPedido
		LEFT JOIN TA_Operacion AS TAO  (NOLOCK)
		ON SP.IdSolicitudPedido = TAO.IdDocumento   
		LEFT JOIN TA_Estatus AS TE  (NOLOCK)
		ON TAO.IdEstatusOperacion   = TE.IdEstatus
		LEFT JOIN CC_CentroCosto AS CC  (NOLOCK)
		ON SP.IdCentroCosto = CC.IdCentroCosto
		INNER JOIN S_Usuario AS U  (NOLOCK)
		ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
		ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK)
		ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.DEA_AdjuntoPR PR  (NOLOCK)
		ON SP.IdSolicitudPedido = PR.IdSolicitudPedido
		LEFT JOIN MM_Localidades LC (NOLOCK)
			ON SP.IdLocalidad = LC.Id
	WHERE (SP.IdUsuarioSolicitante = @IdUsuario or @IdTipoUsuario NOT IN (9))
		AND SP.IdProveedor = @IdProveedor 
		AND ISNULL(TAO.IdTipoOperacion, 2)=2 
		AND ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)<>1
		AND (ISNULL(TE.IdEstatus,9) = @Estatus OR @Estatus = 0)
		AND CAST(SP.FechaAlta AS date) BETWEEN CAST(@FechaInicio AS date) AND CAST(@FechaFin AS date)
	ORDER BY SP.FechaAlta DESC      
  END

END

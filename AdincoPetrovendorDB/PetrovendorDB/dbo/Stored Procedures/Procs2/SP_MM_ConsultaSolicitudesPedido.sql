CREATE PROCEDURE [dbo].[SP_MM_ConsultaSolicitudesPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int,
	@Estatus int,
	@IdTipoUsuario INT,	
    @IdContrato    INT = null,
    @FechaRegistro DATETIME = null
	
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
		ISNULL(USO.Nombre,U.Nombre) AS NombreUsuario,
		TAO.Descripcion,
		AC.NombreAreaContractual AS AreaContractual	,
		PR.ID_PR,
		Contrato = c.NumeroContrato
	FROM MM_SolicitudPedido AS SP 
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido 
		INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido  
		INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion  
		LEFT JOIN CC_CentroCosto AS CC ON SP.IdCentroCosto = CC.IdCentroCosto
		INNER JOIN S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.DEA_AdjuntoPR PR ON PR.IdSolicitudPedido=SP.IdSolicitudPedido
		LEFT JOIN S_Usuario AS USO ON USO.IdUsuario = SP.Solicitante
	WHERE (SP.IdUsuarioSolicitante = @IdUsuario or @IdTipoUsuario NOT IN (9))
		AND SP.IdProveedor = @IdProveedor 
		AND ISNULL(TAO.IdTipoOperacion, 2)=2 
		AND ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)<>1
		AND (ISNULL(TE.IdEstatus,9) = @Estatus OR @Estatus = 0)
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
		ISNULL(USO.Nombre,U.Nombre) AS NombreUsuario,
		TAO.Descripcion,
		AC.NombreAreaContractual AS AreaContractual,
		PR.ID_PR,
		Contrato = c.NumeroContrato
	FROM MM_SolicitudPedido AS SP 
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido 
		LEFT JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido  
		LEFT JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion  
		LEFT JOIN CC_CentroCosto AS CC ON SP.IdCentroCosto = CC.IdCentroCosto
		INNER JOIN S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.DEA_AdjuntoPR PR ON PR.IdSolicitudPedido=SP.IdSolicitudPedido
		LEFT JOIN S_Usuario AS USO ON USO.IdUsuario = SP.Solicitante
	WHERE (SP.IdUsuarioSolicitante = @IdUsuario or @IdTipoUsuario NOT IN (9))
		AND SP.IdProveedor = @IdProveedor 
		AND ISNULL(TAO.IdTipoOperacion, 2)=2 
		AND ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)<>1
		AND (ISNULL(TE.IdEstatus,9) = @Estatus OR @Estatus = 0)
	ORDER BY SP.FechaAlta DESC      
  END

END
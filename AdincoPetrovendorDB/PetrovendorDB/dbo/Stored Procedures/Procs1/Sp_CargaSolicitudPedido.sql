-- =============================================
-- Author:		Pedro Acuña
-- Create date: 14-08-2019
-- Description:	Carga las solicitudes filtradas por contrato
-- =============================================

CREATE PROCEDURE Sp_CargaSolicitudPedido
AS
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
		AC.NombreAreaContractual AS AreaContractual		 
	FROM MM_SolicitudPedido AS SP 
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido 
		INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido  
		INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion  
		LEFT JOIN CC_CentroCosto AS CC ON SP.IdCentroCosto = CC.IdCentroCosto
		INNER JOIN S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual
	WHERE  ISNULL(TAO.IdTipoOperacion, 2)=2 
		AND ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)<>1
		AND (ISNULL(TE.IdEstatus,9) <> 9)
	ORDER BY SP.FechaAlta DESC     
END


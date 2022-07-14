USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Sp_CargaSolicitudPedido'
)
    DROP PROCEDURE Sp_CargaSolicitudPedido;

/****** Object:  StoredProcedure [dbo].[Sp_CargaSolicitudPedido]    Script Date: 12/07/2022 12:20:58 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 14-08-2019
-- Description:	Carga las solicitudes filtradas por contrato
-- =============================================
--=============================================
-- Author:		Daniel AC
-- Create date: 13/07/2022
-- Description:	Orden de tablas 
--=============================================
CREATE PROCEDURE [dbo].[Sp_CargaSolicitudPedido]
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
	FROM MM_SolicitudPedido AS SP (NOLOCK) 
		JOIN MM_TipoSolicitudPedido AS TSP (NOLOCK) 
			ON SP.IdTipoSolicitudPedido  = TSP.IdTipoSolicitudPedido
		JOIN TA_Operacion AS TAO (NOLOCK) 
			ON SP.IdSolicitudPedido   = TAO.IdDocumento
			AND ISNULL(TAO.IdTipoOperacion, 2)=2 
		JOIN TA_Estatus AS TE (NOLOCK) 
			ON TAO.IdEstatusOperacion  = TE.IdEstatus 
		JOIN S_Usuario AS U (NOLOCK) 
			ON U.IdUsuario = SP.IdUsuarioSolicitante 
		LEFT JOIN CC_CentroCosto AS CC (NOLOCK) 
			ON SP.IdCentroCosto = CC.IdCentroCosto		
		LEFT JOIN Adinco.dbo.CO_Contrato AS C  (NOLOCK) 
			ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC  (NOLOCK) 
			ON C.IdAreaContractual = AC.IdAreaContractual
	WHERE ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)<>1
		AND (ISNULL(TE.IdEstatus,9) <> 9)
	ORDER BY SP.FechaAlta DESC     
END


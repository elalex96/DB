USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_RPT_OCM_AprobadoresPorPedido'
)
    DROP PROCEDURE SP_RPT_OCM_AprobadoresPorPedido;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 12-04-2022
-- Description:	 Se cambian los aprobadores mostrados por los aprobadores de pedido, mostrando la columna Estatus
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/10/2023
-- Description:	se agregan estandares de desarrollo
-- =============================================
CREATE  PROCEDURE [dbo].[SP_RPT_OCM_AprobadoresPorPedido]
	@IdPedido INT
AS
BEGIN
	SELECT
		'Aprobador ' + CAST(T.NoSecuencia AS NVARCHAR(max)) AS NoAprobador,
		T.NoSecuencia, 
		U.Nombre, 
		t.FechaCambioEstatus, 
		t.IdTarea,
		t.IdFirma,
		tae.Nombre as Estatus
	FROM TA_Tarea AS T		
		INNER JOIN TA_Operacion AS TOO (NOLOCK)
			ON T.IdOperacion = TOO.IdOperacion
		INNER JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
			ON TOO.IdDocumento = SP.IdSolicitudPedido 
		INNER JOIN dbo.MM_Pedido AS p (NOLOCK)
			ON sp.IdSolicitudPedido = p.IdSolicitudPedido  
			AND  too.NoVersion = p.Version
		INNER JOIN S_Usuario AS U (NOLOCK)
			on T.IdAprobador = u.IdUsuario 
		INNER JOIN TA_Estatus AS TAE (NOLOCK)
			ON T.IdEstatus = TAE.IdEstatus 
	WHERE p.IdPedido = @IdPedido 
		AND t.IdEstatus = 2 --> CTE APROBADO
		AND TOO.IdTipoOperacion = 9 --> CTE APROBACION DE PEDIDO
	ORDER BY NoSecuencia ASC 		
END



USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_RPT_OCM_AprobadoresPorPedido'
)
    DROP PROCEDURE SP_RPT_OCM_AprobadoresPorPedido;
	/****** Object:  StoredProcedure [dbo].[sp_ENT_DocumentosUltimaVersion]    Script Date: 20/09/2023 01:36:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[SP_RPT_OCM_AprobadoresPorPedido]    Script Date: 30/10/2023 03:35:28 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Daniel AC
-- Create date: 30-10-2023
-- Description:	 Se cambian los aprobadores mostrados por los aprobadores de pedido, mostrando la columna Estatus y que se muestren aunque este en aprobación
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_OCM_AprobadoresPorPedido]
	@IdPedido INT
AS
BEGIN
	SELECT
		'Aprobador ' + CAST(T.NoSecuencia AS NVARCHAR(max)) AS NoAprobador,
		T.NoSecuencia, 
		U.Nombre, 
		T.FechaCambioEstatus, 
		T.IdTarea,
		CASE WHEN T.IdEstatus <> 1 THEN T.IdFirma ELSE '' END IdFirma,
		tae.Nombre as Estatus
	FROM TA_Tarea AS T		
		INNER JOIN TA_Operacion AS TOO (NOLOCK)
			ON T.IdOperacion = TOO.IdOperacion
		INNER JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
			ON TOO.IdDocumento = SP.IdSolicitudPedido 
		INNER JOIN dbo.MM_Pedido AS P (NOLOCK)
			ON SP.IdSolicitudPedido = P.IdSolicitudPedido  
			AND  TOO.NoVersion = P.Version
		INNER JOIN S_Usuario AS U  (NOLOCK)
			on T.IdAprobador = U.IdUsuario 
		INNER JOIN TA_Estatus AS TAE  (NOLOCK)
			ON T.IdEstatus = TAE.IdEstatus 
	WHERE p.IdPedido = @IdPedido 	
		AND TOO.IdTipoOperacion = 9 --> CTE APROBACION DE PEDIDO
	ORDER BY NoSecuencia ASC 		
END
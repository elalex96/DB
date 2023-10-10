USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_ConsultaAprobadoresSolicitudPedido'
)
    DROP PROCEDURE SP_PR_MM_ConsultaAprobadoresSolicitudPedido;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Ac
-- Create date: 15-01-2018
-- Description:	consultar información de aprobadores de solcitud de pedido  
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/10/2023
-- Description:	se agregan estandares de desarrollo
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ConsultaAprobadoresSolicitudPedido] 
	-- Add the parameters for the stored procedure here

@IdSolicitudPedido INT,
@IdProveedor INT,
@IdContrato INT,
@FechaRegistro DATETIME,
@IdUsuario INT 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

		SELECT 
			S.Nombre, 
			T.FechaCambioEstatus AS FechaRegistro,
			T.IdFirma AS FirmaAprobador
		FROM dbo.MM_SolicitudPedido AS SP (NOLOCK)
		INNER JOIN dbo.TA_Operacion AS O (NOLOCK)
			ON SP.IdSolicitudPedido = O.IdDocumento
		INNER JOIN dbo.TA_Tarea AS T (NOLOCK)
			ON O.IdOperacion = T.IdOperacion
		INNER JOIN dbo.S_Usuario AS S (NOLOCK)
			ON T.IdAprobador = S.IdUsuario
		WHERE O.IdDocumento=@IdSolicitudPedido 
			AND SP.IdProveedor=@IdProveedor	
			AND O.IdTipoOperacion=2
		ORDER BY S.Nombre ASC
        
     END;

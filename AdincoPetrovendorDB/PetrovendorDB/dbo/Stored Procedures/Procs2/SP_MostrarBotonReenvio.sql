USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MostrarBotonReenvio'
)
    DROP PROCEDURE SP_MostrarBotonReenvio;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26-03-18
-- Description: saber si se debe mostrar o no el boton  (Cuando al menos haya enviado anteriormente una solicitud de oferta y la fecha de vigencia de la oferta no haya terminado)
--				Si encuentra un registro debe mostrar el boton en caso contrario no 
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE PROCEDURE [dbo].[SP_MostrarBotonReenvio] 
	@IdProveedor INT, 
	@IdTipoProceso INT, 
	@IdSolicitudPedido INT
AS
BEGIN
		SELECT	 
			SP.IdSolicitudPedido, 
			TAO.IdOperacion, 
			TAO.FechaFinalizacion
		FROM MM_SolicitudPedido AS SP (NOLOCK)
			JOIN TA_Operacion AS TAO (NOLOCK)
			ON SP.IdSolicitudPedido = TAO.IdDocumento
			AND SP.IdSolicitudPedido = @IdSolicitudPedido
			AND SP.IdProveedor = @IdProveedor
		WHERE TAO.IdTipoOperacion = 6
			AND SP.Activo = 1
			AND (SP.PeticionEnviada = 1 OR SP.PeticionEnviada IS NOT NULL)
			AND (SP.IdTipoProceso = 2)
			AND ISNULL ( SP.Visible, 1 ) = 1
			AND DATEDIFF ( SECOND, GETDATE (), TAO.FechaFinalizacion) > 0
		ORDER BY SP.IdSolicitudPedido DESC

END

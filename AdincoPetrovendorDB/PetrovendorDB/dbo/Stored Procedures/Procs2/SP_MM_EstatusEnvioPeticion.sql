USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_EstatusEnvioPeticion'
)
    DROP PROCEDURE SP_MM_EstatusEnvioPeticion;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/02/2020>
-- Description:	<Consulta de estatus de peticion oferta>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <23/03/2021>
-- Description:	<Se agregan los datos de comprador asignado y fecha de envio de la peticion oferta>
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/07/2023>
-- Description:	<se implementan estandares de desarrollo>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19-07-2023>
-- Description:	aplicacion de optimizaciones y estandares de desarrollo issue:https://github.com/Adinco/petrovendor/issues/2379
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_EstatusEnvioPeticion] 
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FECHAENVIOPETICIONOFERTA DATETIME;
	DECLARE @USUARIOENVIO NVARCHAR(100);

	SET @FECHAENVIOPETICIONOFERTA = (SELECT 
														TOP 1 CreadoEl 
													FROM MM_PeticionOferta (NOLOCK)
													WHERE IdSolicitudPedido = @IdSolicitudPedido 
													ORDER BY CreadoEl DESC);

	SET @USUARIOENVIO = (SELECT TOP 1 US.Nombre 
											FROM MM_PeticionOferta AS PO (NOLOCK)
												LEFT JOIN S_Usuario AS US (NOLOCK)
													ON PO.CreadoPor = US.IdUsuario
											WHERE IdSolicitudPedido = @IdSolicitudPedido 
											ORDER BY CreadoEl DESC);

	SELECT
		ISNULL(PeticionEnviada,0) AS PeticionEnviada,
		@FECHAENVIOPETICIONOFERTA AS FechaEnvioPeticionOferta,
		@USUARIOENVIO AS UsuarioEnvia
	FROM dbo.MM_SolicitudPedido (NOLOCK)
	WHERE IdSolicitudPedido = @IdSolicitudPedido;

END
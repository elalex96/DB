USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_AD_ConsultaUsuarios'
)
    DROP PROCEDURE USP_SEL_AD_ConsultaUsuarios;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/01/2024>
-- Description:	<Consulta de los usuarios para seleccion>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_AD_ConsultaUsuarios]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdUsuario,
		Nombre,
		Correo
	FROM S_Usuario (NOLOCK)
	WHERE Activo = 1

END

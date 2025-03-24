USE [Adinco]
GO
DROP PROCEDURE IF EXISTS sp_Obten_AP_Tableros
/****** Object:  StoredProcedure [dbo].[sp_Obten_AP_Tableros]    Script Date: 20/03/2025 01:59:38 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reyna Olvera
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/03/2025
-- Description: Se agregan los campos de HeightPX y EsVersionCloud
-- =============================================
CREATE PROCEDURE [dbo].[sp_Obten_AP_Tableros]
	@idContrato INT,
	@idUsuario INT
AS
BEGIN

	SET NOCOUNT ON;
	SELECT
		IdTableroContrato,
		IdContrato,
		NombreMostrar,
		Workbook,
		Sheet,
		Tabs,
		Site,
		DNS,
		U.Nombre,
		UserTableau,
		isnull(MuestraToolbar,0) as MuestraToolbar,
		CreadoEn,
		Activo,
		HeightPX,
		idRol,
		Parametros,
		EsVersionCloud
	FROM
		EN_TableroContrato	TC
	JOIN
		AP_Usuario	U
		ON	TC.CreadoPor	=	U.UsuarioID
	WHERE
		IdContrato	=	@idContrato
END


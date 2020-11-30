-- =============================================
-- Author:		Reyna Olvera
-- Create date: 
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_Obten_AP_Tableros]--3,10061
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
		--Tabs,
		Site,
		--DNS,
		U.Nombre,
		UserTableau,
		isnull(MuestraToolbar,0) as MuestraToolbar,
		CreadoEn,
		Activo,
		HeightPX,
		idRol,
		Parametros
	FROM
		EN_TableroContrato	TC
	JOIN
		AP_Usuario	U
		ON	TC.CreadoPor	=	U.UsuarioID
	WHERE
		IdContrato	=	@idContrato
END


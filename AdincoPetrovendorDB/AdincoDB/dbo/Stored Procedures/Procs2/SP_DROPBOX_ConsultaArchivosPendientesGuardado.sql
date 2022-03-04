USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_DROPBOX_ConsultaArchivosPendientesGuardado]    Script Date: 04/03/2022 01:06:41 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03/03/2022>
-- Description:	<Consulta de archivos y permisos para guardado en dropbpx>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DROPBOX_ConsultaArchivosPendientesGuardado]
	@Verificado BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--TOKEN NECESARIO PARA LIGAR LA CUENTA DE DROPBOX
	DECLARE @TOKEN_DROPBOX VARCHAR(MAX) = 'sl.BDLie6TUH3kGEZvflNpyjXK_my53MULpePpOBcIBa2cXG4gYbSGd1VV2P-mv-y0tgtrL4IIh0wgskgDoxmdPBmqjH8haAc2tx0YMw6tF_j3VW2nFrKDMYOqAjE2AULJkDP1TI0w';

	SELECT @TOKEN_DROPBOX;

	SELECT
		IdArchivoEnvio,--0
		Identificador,--1
		Mime,--2
		Extension,--3
		NombreDocumento,--4
		ISNULL(Bucket,'petrovendor') AS Bucket,--5
		Folder,--6
		Size,--7
		Archivo,--8
		ISNULL(IsFactura,0) AS IsFactura,--9
		ISNULL(IsSoporte,0) AS IsSoporte,--10
		RutaDestino--11
	FROM DR_ArchivosEnvioDropbox
	WHERE ISNULL(Cargado,0) = 0;

END

USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DROPBOX_ConsultaArchivosPendientesGuardado'
)
    DROP PROCEDURE SP_DROPBOX_ConsultaArchivosPendientesGuardado;
	GO
/****** Object:  StoredProcedure [dbo].[SP_DROPBOX_ConsultaArchivosPendientesGuardado]    Script Date: 01/06/2022 10:29:11 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03/03/2022>
-- Description:	<Consulta de archivos y permisos para guardado en dropbpx>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <03/03/2022>
-- Description:	Se manda a llamar la ruta inicial del folder de dropbox
-- =============================================
CREATE PROCEDURE [dbo].[SP_DROPBOX_ConsultaArchivosPendientesGuardado] 
	@Verificado BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--> RUTA RAIZ DONDE SE GUARDARAN LOS ARCHIVOS EN PROCURA
	DECLARE @RUTA_RAIZ_DROPBOX VARCHAR(MAX) = (SELECT TOP 1 RootFolder FROM Adinco..APP_ConfiguracionDropbox WHERE Tipo = 'Initial Folder Dropbox')
	SELECT @RUTA_RAIZ_DROPBOX;	

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
	WHERE ISNULL(Cargado,0) = 0	
	ORDER by IdArchivoEnvio desc;

END



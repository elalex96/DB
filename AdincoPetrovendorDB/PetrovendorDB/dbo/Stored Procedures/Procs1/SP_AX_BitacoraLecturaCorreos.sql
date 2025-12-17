use Petrovendor
GO
DROP PROC IF EXISTS SP_AX_BitacoraLecturaCorreos
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <06/12/2019>
-- Description:	<Registro de bitacora de lectura de correos>
-- =============================================
-- Author:		<LUIS DAVID>
-- Create date: <21/10/2022>
-- Description:	<Se agrega a bitacora cuando el documento no contenga info>
-- =============================================
-- Author:		<LUIS DAVID>
-- Create date: <09/05/2023>
-- Description:	<Se valida el bit de Error para notificar al usuario las columnas invalidas>
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 03/10/2023
-- Description: Petrovendor/2469 Se agrupan los usuarios destinatarios
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 03/10/2023
-- Description: Petrovendor/3209 Se agrupan los usuarios destinatarios
-- =============================================
CREATE PROCEDURE [dbo].[SP_AX_BitacoraLecturaCorreos]
	-- Add the parameters for the stored procedure here
	@Asunto NVARCHAR(MAX),
	@CantidadArchvios INT,
	@FechaLectura DATETIME,
	@FechaEnvio DATETIME,
	@ServicioOperadora NVARCHAR(MAX),
	@CorreoEnviado NVARCHAR(MAX),
	@Para NVARCHAR(MAX),
	@Error BIT
AS
BEGIN
DECLARE @HTML NVARCHAR(MAX),
		@CuentaCorreo varchar(300),
		@CorreosAdinco NVARCHAR(MAX),
		@CorreosOperadora NVARCHAR(MAX) = NULL;
	-- SE CAMBIA EL REMITENTE POR EL CORREO DE NOTIFICACIONES DE ADINCO, --YA QUE DEA TIENE REGLA PARA ENVIAR A SPAM LOS CORREOS QUE PROVIENEN DE PROCURA 
	SELECT @CuentaCorreo = CuentaRegistro  FROM Adinco.dbo.S_CorreoServidor  WHERE Descripcion = 'Notificaciones';
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DROP TABLE IF EXISTS #CorreoConcat
	DROP TABLE IF EXISTS #DATOSCORREO
	CREATE TABLE #DATOSCORREO(
	IsCorreoAdinco bit,
	Correo VARCHAR(300))
	CREATE TABLE #CorreoConcat(
	IsCorreoAdinco bit,
	Correo VARCHAR(300))
    -- Insert statements for procedure here
	INSERT INTO dbo.AX_BitacoraLecturaCorreos
	(
	    Asunto,
	    CantidadArchivos,
	    FechaLectura,
	    FechaEnvio,
	    EnviadoPor,
	    ServicioOperadora,
	    FechaRegBitacora,
		RecibidoPor,
		IsError
	)
	VALUES
	(   @Asunto,       -- Asunto - nvarchar(2000)
	    @CantidadArchvios,         -- CantidadArchivos - int
	    @FechaLectura, -- FechaLectura - datetime
	    @FechaEnvio, -- FechaEnvio - datetime
	    @CorreoEnviado,       -- EnviadoPor - nvarchar(1000)
	    @ServicioOperadora,       -- ServicioOperadora - nvarchar(100)
	    GETDATE(), -- FechaRegBitacora - datetime
		@Para,
		@Error
	    );

	INSERT INTO #DATOSCORREO(IsCorreoAdinco,Correo) 
	SELECT CASE WHEN UPPER(C.Destinatario) LIKE '%ADINCO.MX%'
	THEN 1 ELSE 0 END AS IsCorreoAdinco,
	C.Destinatario
	FROM WDEA_CorreosResumenProcesamiento AS C
	-- SE CONCATENAN Y SE AGRUPAN LOS CORREOS DEPENDIENDO EL DOMINIO
	INSERT INTO #CorreoConcat(
	IsCorreoAdinco,
	Correo)
	SELECT 
    DTC.IsCorreoAdinco, 
    STUFF((SELECT ';'+DTS.Correo
           FROM #DATOSCORREO DTS
           WHERE DTS.IsCorreoAdinco = DTC.IsCorreoAdinco
           FOR XML PATH('')), 1, 1, '') AS ParticipantNames
	FROM #DATOSCORREO DTC
	GROUP BY DTC.IsCorreoAdinco;
	--SE OBTIENEN LOS USUARIOS YA CONCATENADOS
	SET @CorreosOperadora = (SELECT Correo FROM #CorreoConcat WHERE IsCorreoAdinco = 0)
	SET @CorreosAdinco = (SELECT Correo FROM #CorreoConcat WHERE IsCorreoAdinco = 1)
	if (@ServicioOperadora = 'CorreoError' OR @Error = 1)
	begin
		SET @HTML = (SELECT HTML FROM dbo.TA_Correo WHERE Asunto = 'Notificación de Resumen de Lectura de WDEA');
		SET @HTML = (REPLACE(@HTML,'##MENSAJE_GENERAL##',ISNULL(@Asunto,'')));
		SET @HTML = (REPLACE(@HTML,'##MENSAJE_CORRECTOS##',ISNULL('','')));
		SET @HTML = (REPLACE(@HTML,'##MENSAJE_ERRORES##',ISNULL('','')));
		SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));

		SELECT
		ISNULL(@CorreosOperadora,@CorreosAdinco) as Para, 
		CAST(CAST(GETDATE() AS DATE) AS nvarchar) + ' Reporte de interfase ADINCO SAP' as 'Asunto',
		@HTML as 'Mensaje',
		10380 as 'CreadoPor'--Usuario Soporte

	end
END

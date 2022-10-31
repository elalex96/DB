use Petrovendor
go
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <06/12/2019>
-- Description:	<Registro de bitacora de lectura de correos>
-- =============================================
-- Author:		<LUIS DAVID>
-- Create date: <21/10/2022>
-- Description:	<Se agrega a bitacora cuando el documento no contenga info>
-- =============================================
ALTER PROCEDURE [dbo].[SP_AX_BitacoraLecturaCorreos]
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
DECLARE @HTML NVARCHAR(MAX),@IdNotificacion int;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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
	if (@ServicioOperadora = 'CorreoError')
	begin
	SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion);
	SET @HTML = (SELECT HTML FROM dbo.TA_Correo WHERE Asunto = 'Notificación de Resumen de Lectura de WDEA');
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_GENERAL##',ISNULL(@Asunto,'')));
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_CORRECTOS##',ISNULL('','')));
	SET @HTML = (REPLACE(@HTML,'##MENSAJE_ERRORES##',ISNULL('','')));
	SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));
		INSERT INTO Adinco.dbo.S_Notificacion
   (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De
    )
	SELECT
			(@IdNotificacion + ROW_NUMBER() over( order by Destinatario desc)), 
			Destinatario, 
			CAST(CAST(GETDATE() AS DATE) AS nvarchar) + ' Reporte de interfase ADINCO SAP',
			REPLACE(@HTML,'##NOMBRE_USUARIO##',ISNULL(Nombre,'Usuario de ADINCO')), 
			DATEADD(MINUTE, 1, GETDATE()), 
			0, 
			NULL, 
			3, 
			GETDATE(), 
			NULL, 
			NULL,
			'notificaciones@adinco.mx'
	FROM dbo.WDEA_CorreosResumenProcesamiento;
	end
END

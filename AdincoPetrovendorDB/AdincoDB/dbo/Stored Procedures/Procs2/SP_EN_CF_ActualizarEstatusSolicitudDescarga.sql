USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_CF_ActualizarEstatusSolicitudDescarga]    Script Date: 30/06/2022 08:24:05 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/05/2022>
-- Description:	<Actualizar estatus de procesamiento del archivo>
-- =============================================
ALTER PROCEDURE [dbo].[SP_EN_CF_ActualizarEstatusSolicitudDescarga]
	-- Add the parameters for the stored procedure here
	@IdSolicitud INT,
	@IdContrato INT,
	@Folder NVARCHAR(1000),
	@UUID NVARCHAR(1000),
	@NombreArchivo NVARCHAR(1000),
	@Size FLOAT,
	@Meta NVARCHAR(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdNotificacion INT;
	DECLARE @HTML NVARCHAR(MAX) = (SELECT HTML FROM Petrovendor.dbo.TA_Correo WHERE Asunto = 'MENSAJE GENERAL');
	DECLARE @NOMBRE_USUARIO NVARCHAR(1000) = (SELECT
													US.Nombre 
												FROM AP_Usuario AS US
													JOIN EN_CF_SolicitUDescargaCarpetas AS CF
														ON CF.SolicitadoPor = US.UsuarioID
														 AND CF.IdSolicitud = @IdSolicitud);
	DECLARE @CORREO_USUARIO NVARCHAR(1000) = (SELECT
													US.Usuario 
												FROM AP_Usuario AS US
													JOIN EN_CF_SolicitUDescargaCarpetas AS CF
														ON CF.SolicitadoPor = US.UsuarioID
														 AND CF.IdSolicitud = @IdSolicitud);
	DECLARE @RUTA NVARCHAR(MAX) = (SELECT RutaDescargada FROM EN_CF_SolicitUDescargaCarpetas WHERE IdSolicitud = @IdSolicitud);
	DECLARE @CONTRATO NVARCHAR(MAX) = (SELECT Top 1
											C.NumeroContrato + ' - ' + A.NombreAreaContractual
										FROM CO_Contrato AS C
											JOIN CO_AreaContractual AS A
												ON C.IdAreaContractual = A.IdAreaContractual
										WHERE C.IdContrato = @IdContrato);
	DECLARE @MENSAJE NVARCHAR(MAX) = 'Estimado(a) ' + @NOMBRE_USUARIO + '<br><br> Se ha procesado su solicitud de descarga de la ruta "' + @RUTA + '", en el contrato ' + @CONTRATO + '. <br><br>Por lo cual ya es posible descargarlo desde el modulo de Contract Files(https://adinco.mx/2/Entregables/ArchivosEntregables_V2.aspx).'

	SET @HTML = (REPLACE(@HTML,'##MENSAJE_GENERAL##',ISNULL(@MENSAJE,'')));
	SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));


	UPDATE EN_CF_SolicitUDescargaCarpetas
	SET Folder = @Folder,
		UUIDAmazon = @UUID,
		NombreArchivo = @NombreArchivo,
		Size = @Size,
		Meta = @Meta,
		FechaProcesado = GETDATE(),
		Procesado = 1
	WHERE IdSolicitud = @IdSolicitud
		AND ContratoId = @IdContrato;

	SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion);

	--NOTIFICACION DE PROCESAMIENTO
	INSERT INTO Adinco.dbo.S_Notificacion
   (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoEl,
            De,
			CreadoPor
    )
	VALUES
	(
		(@IdNotificacion + 1),
		@CORREO_USUARIO,
		'Solicitud de Descarga de Archivos de Contract Files Finalizada',
		@HTML,
		DATEADD(MINUTE, 1, GETDATE()), 
		0,
		GETDATE(),
		GETDATE(),
		'notificaciones@adinco.mx',
		3
	);

	SELECT 
		Procesado
	FROM EN_CF_SolicitUDescargaCarpetas
	WHERE IdSolicitud = @IdSolicitud
		AND ContratoId = @IdContrato;
END

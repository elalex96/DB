USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'EN_sp_GuardaRelacionDocumentoS3Bitacora'
)
    DROP PROCEDURE EN_sp_GuardaRelacionDocumentoS3Bitacora;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[EN_sp_GuardaRelacionDocumentoS3Bitacora]
@IdBitacora int,
@IdDocumento int,
@IdUsuario int,
@IdContrato int,
@Server varchar(300),
@NombreDocumento varchar(1000)
AS
BEGIN
DECLARE
@pIdNotificacion int,
@Mensaje varchar(1000),
@NombreUsuario varchar(1000) = (SELECT TOP 1
								US.Nombre 
								FROM AP_Usuario AS US (NOLOCK)
								WHERE UsuarioID = @IdUsuario), 
@para varchar(1000) = (SELECT TOP 1
								US.Usuario
								FROM AP_Usuario AS US (NOLOCK)
								WHERE UsuarioID = @IdUsuario),
@HTML varchar(max) = (SELECT HTML FROM TA_Correo (NOLOCK) WHERE Asunto = 'Descarga de Reporte SASISOPA');

	-- SE ACTUALIZA EL PROCESADO
	UPDATE EN_Documentos_BitacoraReporteSASISOPA
	SET Procesado = 1
	WHERE Id = @IdBitacora
	-- SE AGREGA LA BITÁCORA 
	INSERT INTO EN_DocumentosSASISOPA_Relacion(
	IdBitacoraReporte,	IdDocumento,	NombreDocumento) 
	VALUES (
	@IdBitacora,		@IdDocumento,	@NombreDocumento)
	-- SE INSERTA LA NOTIFICACIÓN 
	SET @Mensaje = (CONCAT('Su documento  "',@NombreDocumento,'" está disponible para descargarlo, puede consultarlo ahora.'));
	SET @HTML = (replace(@HTML,'##NombreUsuario##',@NombreUsuario))
	SET @HTML = (replace(@HTML,'##Mensaje##', @Mensaje))
	SET @HTML = (replace(@HTML,'##YEAR_ACTUAL##',CAST(YEAR(getdate()) as varchar(10))))
	SET @HTML = (replace(@HTML,'##URL_TAREA##', @Server))
	
	select @pIdNotificacion = isnull(max(IdNotificacion),0) + 1
			from Adinco..S_Notificacion

	insert into Adinco..S_Notificacion(
				IdNotificacion,			Para,			Asunto,							Mensaje,		
				FechaProgramadaEnvio,	Enviada,		FechaEnvio,		CreadoPor,
				CreadoEl,				ModificadoPor,	ModificadoEl,	De,				EN_MsjEnviado)
				VALUES (
				@pIdNotificacion ,		@para,			'Descargade Reporte SASISOPA',	isnull(@HTML,''),
				getdate(),				0,				null,			1,
				getdate(),				null,			null,			'notificaciones@adinco.mx',null)
END

USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS SP_MM_ActualizarEstatusSolicitudDescarga
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ActualizarEstatusSolicitudDescarga]    Script Date: 20/05/2025 10:21:23 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21/02/2023>
-- Description:	<Actualizar estatus de procesamiento del archivo>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <20/05/2025>
-- Description:	<Retorno de la info de envio de correo>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarEstatusSolicitudDescarga]
	-- Add the parameters for the stored procedure here
	@IdSolicitud INT,
	@IdContrato INT,
	@Folder NVARCHAR(1000),
	@UUID NVARCHAR(1000),
	@NombreArchivo NVARCHAR(1000),
	@Size FLOAT,
	@Meta NVARCHAR(1000),
	@Tipo VARCHAR(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdNotificacion INT;
	DECLARE @HTML NVARCHAR(MAX) = (SELECT HTML FROM Petrovendor.dbo.TA_Correo (NOLOCK) WHERE Asunto = 'MENSAJE GENERAL');
	DECLARE @NOMBRE_USUARIO NVARCHAR(1000) = (SELECT
													US.Nombre 
												FROM S_Usuario AS US
													JOIN [MM_SolicitudesDescargaProcesos] AS CF (NOLOCK)
														ON US.IdUsuario = CF.IdUsuarioSolicitante
														 AND CF.IdSolicitud = @IdSolicitud);
	DECLARE @CORREO_USUARIO NVARCHAR(1000) = (SELECT
													US.Correo 
												FROM S_Usuario AS US (NOLOCK)
													JOIN [MM_SolicitudesDescargaProcesos] AS CF (NOLOCK)
														ON CF.IdUsuarioSolicitante = US.IdUsuario
														 AND CF.IdSolicitud = @IdSolicitud);

	DECLARE @FECHAINICIO NVARCHAR(30) = (SELECT CAST(FechaInicio AS nvarchar) FROM [MM_SolicitudesDescargaProcesos] (NOLOCK) WHERE IdSolicitud = @IdSolicitud);
	DECLARE @FECHAFIN NVARCHAR(30) = (SELECT CAST(FechaFin AS nvarchar) FROM [MM_SolicitudesDescargaProcesos] (NOLOCK) WHERE IdSolicitud = @IdSolicitud);

	DECLARE @CONTRATO NVARCHAR(MAX) = (SELECT Top 1
											C.NumeroContrato + ' - ' + A.NombreAreaContractual
										FROM Adinco..CO_Contrato AS C (NOLOCK)
											JOIN Adinco..CO_AreaContractual AS A (NOLOCK)
												ON C.IdAreaContractual = A.IdAreaContractual
										WHERE C.IdContrato = @IdContrato);

	DECLARE @MENSAJE NVARCHAR(MAX) = '',@ASUNTO VARCHAR(MAX);
	IF @Tipo = 'ACEPTACION'
	BEGIN
			set @MENSAJE = ('Estimado(a) ' + @NOMBRE_USUARIO + '<br><br> Se ha procesado su solicitud de descarga de los archivos del rango de fechas de ' + @FECHAINICIO + ' al ' + @FECHAFIN + ', en el contrato ' + @CONTRATO + '. <br><br>Por lo cual
 ya es posible descargarlo desde el modulo de Descarga de Información de Aceptaciones de Pedido(https://procura.adinco.mx/01Proveedores/RPT_DescargaInfoSoporteAceptaciones.aspx).')
			set @ASUNTO = ('Solicitud de Descarga de Archivos de Soporte de Aceptación de Pedido Finalizada')
	END
	IF @Tipo = 'PEDIDO'
	BEGIN
		set @MENSAJE = ('Estimado(a) ' + @NOMBRE_USUARIO + '<br><br> Se ha procesado su solicitud de descarga de los Reportes del rango de fechas de ' + @FECHAINICIO + ' al ' + @FECHAFIN + ', en el contrato ' + @CONTRATO + '. <br><br>Por lo cual
 ya es posible descargarlo desde el modulo de Descarga de Información de Pedidos(https://procura.adinco.mx/01Proveedores/RPT_DescargaInfoPedidos.aspx).')
		set @ASUNTO = ('Solicitud de Descarga de Reportes de Pedidos Finalizada')
	END

	SET @HTML = (REPLACE(@HTML,'##MENSAJE_GENERAL##',ISNULL(@MENSAJE,'')));
	SET @HTML = (REPLACE(@HTML,'##ANIO_ACTUAL##',YEAR(GETDATE())));


	UPDATE [MM_SolicitudesDescargaProcesos]
	SET Folder = @Folder,
		UUIDAmazon = @UUID,
		NombreArchivo = @NombreArchivo,
		Size = @Size,
		Meta = @Meta,
		FechaFinalProcesamiento = GETDATE(),
		Procesado = 1
	WHERE IdSolicitud = @IdSolicitud
		AND IdContrato = @IdContrato;

	SELECT 
		Procesado,
		@CORREO_USUARIO AS Para,
		@ASUNTO AS Asunto,
		@HTML AS HTML,
		1 AS CreadoPor
	FROM [MM_SolicitudesDescargaProcesos] (NOLOCK)
	WHERE IdSolicitud = @IdSolicitud
		AND IdContrato = @IdContrato;
END

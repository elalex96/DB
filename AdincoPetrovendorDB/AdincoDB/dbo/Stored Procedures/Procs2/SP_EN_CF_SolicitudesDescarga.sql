-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/05/2022>
-- Description:	<Consulta de las solicitudes de descarga de archivos en contract files>
-- =============================================
CREATE PROCEDURE SP_EN_CF_SolicitudesDescarga
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT
		SolicitadoEl,
		US.Nombre AS SolicitadoPor,
		CASE	
			WHEN ISNULL(SD.Procesado,0) = 0 THEN 'Procesando Archivos..'
			WHEN ISNULL(SD.Procesado,0) = 1 THEN 'Listo para Descargar'
		END AS Estatus,
		CASE  
		WHEN ISNULL(SD.Procesado,0) = 0 THEN 'label label-warning'
		WHEN ISNULL(SD.Procesado,0) = 1 THEN 'label label-success'
	END AS span,
		SD.UltimaDescarga,
		SD.RutaDescargada,
		SD.Folder,
		SD.UUIDAmazon,
		SD.NombreArchivo,
		SD.Meta
	FROM EN_CF_SolicitUDescargaCarpetas AS SD
	JOIN AP_Usuario AS US
		ON SD.SolicitadoPor = US.UsuarioID
	WHERE ContratoId = @IdContrato
	ORDER BY SolicitadoEl DESC;

END

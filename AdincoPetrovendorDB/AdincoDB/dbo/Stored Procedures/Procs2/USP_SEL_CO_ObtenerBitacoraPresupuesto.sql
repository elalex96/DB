IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_CO_ObtenerBitacoraPresupuesto'
    )
    DROP PROCEDURE USP_SEL_CO_ObtenerBitacoraPresupuesto;
GO
CREATE PROCEDURE USP_SEL_CO_ObtenerBitacoraPresupuesto
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
SET NOCOUNT ON;
SELECT CO_BitacoraPresupuesto.IdCarga,
       CO_Contrato.NumeroContrato + ' - ' + ISNULL(CO_AreaContractual.NombreAreaContractual, '') AS Contrato,
       AWS_Documentos.NombreArchivo AS Archivo,
       ISNULL(CO_BitacoraPresupuesto.DetalleAnalisis, '') AS DetalleAnalisis,
       CO_BitacoraPresupuesto.CreadoEl,
       AP_Usuario.Nombre AS CreadoPor,
       ISNULL(CO_BitacoraPresupuesto.DetalleInsercion, 'NA') AS DetalleInsercion,
      ISNULL(LTRIM(CO_BitacoraPresupuesto.IdPresupuesto), 'NA') AS Presupuesto,
	   ISNULL(CO_TipoProgramaActividad.TipoPrograma, '') AS TipoPrograma,
	   ISNULL(CO_BitacoraPresupuesto.Tipo, '')	AS Tipo
FROM CO_BitacoraPresupuesto (NOLOCK)
    JOIN CO_Contrato (NOLOCK)
        ON CO_BitacoraPresupuesto.IdCOntrato = CO_Contrato.IdContrato
    JOIN CO_AreaContractual (NOLOCK)
        ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
    JOIN AWS_Documentos (NOLOCK)
        ON CO_BitacoraPresupuesto.IdArchivoAWS = AWS_Documentos.AWSDocumentoId
    JOIN AP_Usuario (NOLOCK)
        ON CO_BitacoraPresupuesto.CreadoPor = AP_Usuario.UsuarioID
	LEFT JOIN
		CO_TipoProgramaActividad (NOLOCK)
		ON CO_BitacoraPresupuesto.IdTipoProgramaActividad = CO_TipoProgramaActividad.IdTipoProgramaActividad
ORDER BY CO_BitacoraPresupuesto.IdCarga DESC

END

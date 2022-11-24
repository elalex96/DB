-- =============================================
-- Author:		Reyna Olvera
-- Create date: 
-- Description:	
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/12/2021
-- Description:	Se muestra el comentario aunque no este desactivado(historial de cambios en fechas)
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_InfoContratoEntregableInstancia] --3,59072,10061
    @IdContrato INT,
    @idInstanciaEntregable INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @ComentarioDesactivacion VARCHAR(500) = '';

    SELECT TOP 1
           @ComentarioDesactivacion = Comentario
    FROM dbo.EN_HistorialAprobacionesLineaTiempo
    WHERE idInstanciaEntregable = @idInstanciaEntregable
          AND idTipoOperacion = 6
    ORDER BY IdHistorialAprobacionesVersion DESC;

    SELECT CE.IdContratoEntregable,
           CE.IdContrato,
           IE.idInstanciaEntregable,
           ISNULL(FE.FrecuenciaEntregable, '') AS Frecuencia,
           ISNULL(EN.Consecutivo, '') Consecutivo,
           ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
           CE.IdEntregable,
           CE.AreaResponsable,
           ISNULL(IE.FechasLimiteAprobacion, GETDATE()) AS FechaLimiteEntrega,
           CE.CreadoPor,
           CE.CreadoEl,
           CE.ModificadoPor,
           CE.ModificadoEl,
           CE.Activo,
           ISNULL(IE.FechaCalculadaEntregaReg, GETDATE()) AS FechaLimiteEntregaRegulador,
           EN.DocumentoEntregable AS DocumentoEntregable,
           CASE ISNULL(AEE.idUsuario, '')
               WHEN '' THEN
                   AE.idUsuario
               ELSE
                   AEE.idUsuario
           END AS UsuarioElaborador,
           CASE ISNULL(APE.idUsuario, '')
               WHEN '' THEN
                   AP.idUsuario
               ELSE
                   APE.idUsuario
           END AS UsuarioAprobador,
           IE.Activo AS ActivoInstancia,
           @ComentarioDesactivacion AS ComentarioDesactivacion
    FROM EN_Entregable EN (NOLOCK)
		 JOIN EN_ContratoEntregable CE (NOLOCK)
			 ON CE.IdContrato=@IdContrato
				AND EN.IdEntregable=CE.IdEntregable
		 JOIN EN_InstanciasEntregable IE (NOLOCK)
			  ON CE.IdContratoEntregable= IE.IdContratoEntregable
				 AND IE.idInstanciaEntregable = @idInstanciaEntregable
		 JOIN dbo.EN_Actividad AE (NOLOCK)
			  ON CE.IdContratoEntregable = AE.IdContratoEntregable
				 AND AE.EstadoID = 10000
		 JOIN dbo.EN_Actividad AP (NOLOCK)
			  ON CE.IdContratoEntregable = AP.IdContratoEntregable
				 AND AP.EstadoID = 10002
		JOIN EN_MarcoLegal AS ML (NOLOCK)
			  ON EN.IdMarcoLegal = ML.IdMarcoLegal
		JOIN [EN_FrecuenciaEntregable] AS FE (NOLOCK)
			  ON EN.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
		LEFT JOIN dbo.EN_ExcepcionesActividad AEE (NOLOCK)
				  ON AEE.IdInstanciasEntregables = @idInstanciaEntregable
				     AND AE.ActividadID = AEE.ActividadIDExcepcion
				     AND AEE.EstadoID = 10000
		LEFT JOIN dbo.EN_ExcepcionesActividad APE (NOLOCK)
				  ON APE.IdInstanciasEntregables = @idInstanciaEntregable
					 AND AP.ActividadID = APE.ActividadIDExcepcion
					 AND APE.EstadoID = 10002

END;
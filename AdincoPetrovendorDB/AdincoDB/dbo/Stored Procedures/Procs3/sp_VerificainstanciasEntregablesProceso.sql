-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Verifica las instancias de los procesos
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerificainstanciasEntregablesProceso] --3,10061,11128--,10030--SIMULACION 
    @idContrato INT,
    @idUsuario INT,
    @idInstanciaActividad INT
AS
BEGIN
    SET LANGUAGE spanish;
    SELECT      E.IdEntregable,
                A.EstadoID,
                CE.IdContratoEntregable,
                I.idInstanciaEntregable AS idInstanciaEntregable,
                E.DocumentoEntregable AS DocumentoEntregable,
                FechasLimiteAprobacion,
                E.Consecutivo,
                ISNULL(ML.MarcoLegal, '') AS MarcoLegal,
                ISNULL(E.TituloAnexo, '') AS TituloAnexo,
                ISNULL(E.Capitulo, '') AS Capitulo,
                CE.AreaResponsable,
                FE.FrecuenciaEntregable,
                R.Regulador,
                Es.NombreEstado AS Estatus
     FROM EN_Entregable E (NOLOCK)
			INNER JOIN EN_ContratoEntregable CE (NOLOCK)
				 ON CE.IdContrato=@IdContrato
					AND E.IdEntregable = CE.IdEntregable
					AND CE.Activo = 1 
					AND E.IsActivo = 1
			JOIN dbo.EN_InstanciasEntregables_InstanciaActividad IEIA (NOLOCK)
				 ON IEIA.idInstanciaActividad = @idInstanciaActividad	
			JOIN EN_InstanciasEntregable I (NOLOCK)
				 ON IEIA.idInstanciaEntregable = I.idInstanciaEntregable 
					AND I.IdContratoEntregable = CE.IdContratoEntregable
			JOIN EN_FrecuenciaEntregable FE (NOLOCK) 
			     ON E.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
			JOIN EN_Actividad A (NOLOCK)
				 ON I.ActividadID = A.ActividadID
			JOIN dbo.EN_Estado Es (NOLOCK)
				 ON A.EstadoID = Es.EstadoID
			LEFT JOIN EN_AREA Are (NOLOCK)
				 ON CE.IdArea = Are.IdArea
			LEFT JOIN CO_Regulador R (NOLOCK)
				 ON E.IdRegulador = R.IdRegulador
			LEFT JOIN EN_MarcoLegal AS ML (NOLOCK)
			     ON E.IdMarcoLegal = ML.IdMarcoLegal
     ORDER BY FechasLimiteAprobacion ASC;


END
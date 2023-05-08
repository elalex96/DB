CREATE PROCEDURE [dbo].[EN_EntregablesRevisarUsuario] --10061,3
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/04/2018
-- Description:	Para que el usuario pueba ver que archivos tiene que aprobar 
-- =============================================
    SET NOCOUNT ON;

    SELECT E.IdEntregable AS idEntregable,
           CE.IdContratoEntregable AS idContratoEntregable,
           I.idInstanciaEntregable AS idinstanciaEntregable,
           E.DocumentoEntregable AS DocumentoEntregable,
           FechasLimiteAprobacion AS FechasLimiteAprobacion,
           E.Consecutivo AS Consecutivo,
           ML.MarcoLegal AS MarcoLegal,
           E.TituloAnexo AS TituloAnexo,
           E.Capitulo AS Capitulo,
           EN_FrecuenciaEntregable.FrecuenciaEntregable AS FrecuenciaEntregable,
           CO_Regulador.Regulador AS Regulador,
           Es.NombreEstado AS Estatus,
           A.EstadoID AS idEstatus,
           I.BitContieneAcuse
    FROM EN_InstanciasEntregable I
   JOIN EN_Actividad A ON I.ActividadID = A.ActividadID
   JOIN EN_Estado Es ON A.EstadoID = Es.EstadoID
   JOIN EN_ContratoEntregable CE ON CE.IdContratoEntregable = I.IdContratoEntregable
                                     AND CE.IdContrato = @idContrato
   JOIN EN_HistorialAprobacionesLineaTiempo H ON I.idInstanciaEntregable = H.idInstanciaEntregable
                                                  AND idTipoOperacion = 3
                                                  AND H.CreadoPor = @idUsuario
   JOIN EN_Entregable E ON CE.IdEntregable = E.IdEntregable
	AND E.BITJOA	=	0
   JOIN EN_FrecuenciaEntregable ON E.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable
   LEFT JOIN CO_Regulador ON E.IdRegulador = CO_Regulador.IdRegulador
   LEFT JOIN EN_MarcoLegal AS ML ON E.IdMarcoLegal = ML.IdMarcoLegal
    GROUP BY E.IdEntregable,
             CE.IdContratoEntregable,
             I.idInstanciaEntregable,
             E.DocumentoEntregable,
             FechasLimiteAprobacion,
             E.Consecutivo,
             ML.MarcoLegal,
             E.TituloAnexo,
             E.Capitulo,
             EN_FrecuenciaEntregable.FrecuenciaEntregable,
             CO_Regulador.Regulador,
             Es.NombreEstado,
             A.EstadoID,
             I.BitContieneAcuse;
END;

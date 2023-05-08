CREATE PROCEDURE [dbo].[EN_EntregablesTodos]--10082,3
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
                -- E.Articulo,
                EN_FrecuenciaEntregable.FrecuenciaEntregable AS FrecuenciaEntregable,
                CO_Regulador.Regulador AS Regulador,
				  CONCAT('En ', ES.NombreEstado) AS Estatus
      FROM      EN_InstanciasEntregable I
      JOIN      EN_Actividad A
        ON I.ActividadID            = A.ActividadID
      JOIN      dbo.EN_Estado ES
        ON ES.EstadoID              = A.EstadoID
      JOIN      EN_ContratoEntregable CE
        ON CE.IdContratoEntregable  = I.IdContratoEntregable
       AND CE.IdContrato            = @idContrato
     INNER JOIN EN_Entregable E
        ON CE.IdEntregable          = E.IdEntregable
		AND E.BITJOA = 0
     INNER JOIN EN_MarcoLegal AS ML
        ON E.IdMarcoLegal           = ML.IdMarcoLegal
     INNER JOIN EN_FrecuenciaEntregable
        ON E.IdFrecuenciaEntregable = EN_FrecuenciaEntregable.IdFrecuenciaEntregable
     INNER JOIN CO_Regulador
        ON E.IdRegulador            = CO_Regulador.IdRegulador
     INNER JOIN AP_Usuario U
        ON U.UsuarioID              = A.idUsuario
     WHERE      A.EstadoID IN( 10001,10002)
       AND      A.idUsuario     = @idUsuario;
END;

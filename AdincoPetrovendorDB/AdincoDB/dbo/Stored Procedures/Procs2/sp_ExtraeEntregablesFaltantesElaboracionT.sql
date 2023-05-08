-- =============================================
-- Author:	Reyna Olvera
-- Create date: 2018-11-08
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_ExtraeEntregablesFaltantesElaboracionT] -- 3,10061
    @IdContrato INT,
    @idUsuario INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT IE.idInstanciaEntregable AS idInstanciaEntregable,
	ce.IdEntregable AS IdEntregable,
	CE.IdContratoEntregable AS IdContratoEntregable,
	EN.IdRegulador AS idRegulador,
           NumeroContrato,
           DocumentoEntregable,
           R.Regulador AS Regulador,
           M.MarcoLegal AS MarcoLegal,
           FechasLimiteElaboracion,
           FechasLimiteAprobacion,
           E.Estatus,
		   f.FrecuenciaEntregable AS FrecuenciaEntregable
    FROM EN_InstanciasEntregable IE
        JOIN EN_ContratoEntregable CE
            ON CE.IdContratoEntregable = IE.IdContratoEntregable
        JOIN EN_Estatus E
            ON E.idEstatus = IE.Estatus
        JOIN CO_Contrato C
            ON C.IdContrato = CE.IdContrato
        JOIN EN_Entregable EN
            ON EN.IdEntregable = CE.IdEntregable
        JOIN dbo.CO_Regulador R
            ON R.IdRegulador = EN.IdRegulador
        JOIN dbo.EN_MarcoLegal M
            ON M.IdMarcoLegal = EN.IdMarcoLegal
			JOIN dbo.EN_FrecuenciaEntregable f ON f.IdFrecuenciaEntregable = EN.IdFrecuenciaEntregable
    WHERE IE.Estatus IN ( 10000, 10005 )
          AND CE.UsuarioElabora = @idUsuario
		  ORDER BY IE.FechasLimiteAprobacion ASC

	
END;
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

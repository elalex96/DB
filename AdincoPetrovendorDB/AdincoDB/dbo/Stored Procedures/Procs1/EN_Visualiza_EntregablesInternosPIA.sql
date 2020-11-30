CREATE PROCEDURE [dbo].[EN_Visualiza_EntregablesInternosPIA] 
    @pIdEntregable INT,
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 09/04/2018
-- Description:	Visualiza los entregables internos
-- =============================================
    SET NOCOUNT ON;

    SELECT FE.FrecuenciaEntregable,
           e.IdEntregable,
           e.DocumentoEntregable,
           e.Descripcion,
           e.IdFrecuenciaEntregable,
           --e.CreadoPor,
           u.Nombre AS CreadoPor,
           e.CreadoEn,
           IsActivo = CAST(ISNULL(e.IsActivo, 0) AS BIT),
           e.Consecutivo,
           R.NombreRegulador,
           R.IdRegulador,
           RE.IdReceptorEntregable,
           RE.ReceptorEntregable,
           CE.IdContratoEntregable,
           e.EsDeProceso,
		   PI.IdProgramaImplementa,
		   e.Capitulo,
		   e.Articulo,
		   cepia.IdProgramaImplementaAccion,
		   Subfuncion,
		   FocalPoint,
		   AccountableCompliance,
		   Accountable
    FROM EN_Entregable e
    JOIN dbo.EN_ContratoEntregable CE
		ON e.IdEntregable = CE.IdEntregable
        AND CE.IdContrato = @idContrato
		AND E.BITJOA = 0
    JOIN AP_Usuario u ON e.CreadoPor = u.UsuarioID
	JOIN EN_ContratoEntregableProgramaImplementaAcciones CEPIA ON ce.IdContratoEntregable=CEPIA.IdContratoEntregable
	JOIN CO_ProgramaImplementaAcciones PIA ON CEPIA.IdProgramaImplementaAccion = PIA.IdProgramaImplementaAccion
	JOIN CO_ProgramaImplementaElemento PIE ON PIA.IdProgramaImplementaElemento=PIE.IdProgramaImplementaElemento
	JOIN CO_ProgramaImplementaPoliticas  PIP ON PIE.IdProgramaImplementaPolitica=PIP.IdProgramaImplementaPolitica 
	JOIN CO_ProgramaImplementa PI ON PI.IdProgramaImplementa = PIP.IdProgramaImplementa
    LEFT JOIN dbo.EN_FrecuenciaEntregable FE ON e.IdFrecuenciaEntregable = FE.IdFrecuenciaEntregable
    LEFT JOIN dbo.CO_Regulador R ON e.IdRegulador = R.IdRegulador
    LEFT JOIN dbo.EN_ReceptorEntregable RE ON e.IdReceptorEntregable = RE.IdReceptorEntregable
    WHERE @pIdEntregable IN ( 0, e.IdEntregable )
          AND e.BitInterno = 1
          AND CE.IdContrato = @idContrato
    ORDER BY IdEntregable DESC;

END;
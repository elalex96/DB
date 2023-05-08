-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26/08/2019
-- Description:
-- =============================================

CREATE PROCEDURE [dbo].[sp_EN_ExtraeProgramaImplementaAccion]--10061,3,1
    @idUsuario INT,
    @IdContrato INT,
    @IdProgramaImplementaAccion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @idConEntregableProgramaImpAccion INT = 0;
    SELECT @idConEntregableProgramaImpAccion = idConEntregableProgramaImpAccion
    FROM dbo.EN_ContratoEntregableProgramaImplementaAcciones
    WHERE IdProgramaImplementaAccion = @IdProgramaImplementaAccion;

    IF (@idConEntregableProgramaImpAccion <> 0)
    BEGIN
        SELECT CASE
                   WHEN EPIA.idConEntregableProgramaImpAccion IS NOT NULL THEN
                       1
                   ELSE
                       0
               END AS ContieneEntregable,
               EPIA.idConEntregableProgramaImpAccion,
               EPIA.IdContratoEntregable,
               CE.IdEntregable,
               PIT.IdContrato,
               PIA.IdProgramaImplementaAccion,
               PI.IdTipoPrograma,
               PIT.Descripcion AS Programa,
               PIP.Descripcion AS Politica,
               PIE.Descripcion AS Elemento,
               PIA.Descripcion AS Accion
        FROM dbo.CO_ProgramaImplementaAcciones PIA
        JOIN CO_ProgramaImplementaElemento PIE ON PIA.IdProgramaImplementaAccion = @IdProgramaImplementaAccion
                                                  AND PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
        JOIN dbo.CO_ProgramaImplementaPoliticas PIP ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
        JOIN CO_ProgramaImplementa PI ON PIP.IdProgramaImplementa = PI.IdProgramaImplementa
        JOIN dbo.CO_ProgramaImplementacionTipo PIT ON PI.IdTipoPrograma = PIT.Id
        JOIN dbo.EN_ContratoEntregableProgramaImplementaAcciones EPIA ON EPIA.idConEntregableProgramaImpAccion = @idConEntregableProgramaImpAccion
                                                                         AND PIA.IdProgramaImplementaAccion = EPIA.IdProgramaImplementaAccion
        JOIN dbo.EN_ContratoEntregable CE ON EPIA.IdContratoEntregable = CE.IdContratoEntregable
        WHERE PIA.IdProgramaImplementaAccion = @IdProgramaImplementaAccion;
    END;
    ELSE
    BEGIN
        SELECT 0 AS ContieneEntregable,
               0 AS idConEntregableProgramaImpAccion,
               0 AS IdContratoEntregable,
               0 AS IdEntregable,
               PIT.IdContrato,
               PIA.IdProgramaImplementaAccion,
               PI.IdTipoPrograma,
               PIT.Descripcion AS Programa,
               PIP.Descripcion AS Politica,
               PIE.Descripcion AS Elemento,
               PIA.Descripcion AS Accion
        FROM dbo.CO_ProgramaImplementaAcciones PIA
        JOIN CO_ProgramaImplementaElemento PIE ON PIA.IdProgramaImplementaAccion = @IdProgramaImplementaAccion
                                                  AND PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
        JOIN dbo.CO_ProgramaImplementaPoliticas PIP ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
        JOIN CO_ProgramaImplementa PI ON PIP.IdProgramaImplementa = PI.IdProgramaImplementa
        JOIN dbo.CO_ProgramaImplementacionTipo PIT ON PI.IdTipoPrograma = PIT.Id
        WHERE PIA.IdProgramaImplementaAccion = @IdProgramaImplementaAccion;
    END;
END;


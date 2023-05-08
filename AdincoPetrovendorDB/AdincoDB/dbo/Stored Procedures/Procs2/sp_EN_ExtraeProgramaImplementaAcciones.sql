-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26/08/2019
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeProgramaImplementaAcciones]-- 10061,3,1,0,0
    @idUsuario INT,
    @IdContrato INT,
    @IdTipoPrograma INT,
    @idContratoEntregable INT,
    @MuestraRelacionado INT
AS
BEGIN
    SET NOCOUNT ON;
    IF (@idContratoEntregable > 0)
    BEGIN
        SELECT CASE
                   WHEN EPIA.idConEntregableProgramaImpAccion IS NOT NULL THEN
                       1
                   ELSE
                       0
               END AS Seleccionado,
               EPIA.idConEntregableProgramaImpAccion,
               PIT.IdContrato,
               PIA.IdProgramaImplementaAccion,
               PI.IdTipoPrograma,
               PIT.Descripcion AS Programa,
               PIP.Descripcion AS Politica,
               PIE.Descripcion AS Elemento,
               PIA.Descripcion AS Accion
        FROM CO_ProgramaImplementacionTipo PIT
        JOIN CO_ProgramaImplementa PI ON PIT.Id = PI.IdTipoPrograma
                                         AND PIT.Id = @IdTipoPrograma
        JOIN CO_ProgramaImplementaPoliticas PIP ON PI.IdProgramaImplementa = PIP.IdProgramaImplementa
        JOIN CO_ProgramaImplementaElemento PIE ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
        JOIN CO_ProgramaImplementaAcciones PIA ON PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
        LEFT JOIN EN_ContratoEntregableProgramaImplementaAcciones EPIA ON PIA.IdProgramaImplementaAccion = EPIA.IdProgramaImplementaAccion
                                                                          AND IdContratoEntregable = @idContratoEntregable
        WHERE PIT.Id = @IdTipoPrograma;
    END;
    ELSE
    BEGIN

        SELECT CASE
                   WHEN EPIA.idConEntregableProgramaImpAccion IS NOT NULL THEN
                       1
                   ELSE
                       0
               END AS Seleccionado,
               EPIA.idConEntregableProgramaImpAccion,
               PIT.IdContrato,
               PIA.IdProgramaImplementaAccion,
               PI.IdTipoPrograma,
               PIT.Descripcion AS Programa,
               PIP.Descripcion AS Politica,
               PIE.Descripcion AS Elemento,
               PIA.Descripcion AS Accion
        FROM CO_ProgramaImplementacionTipo PIT
        JOIN CO_ProgramaImplementa PI ON PIT.Id = PI.IdTipoPrograma
                                         AND PIT.Id = @IdTipoPrograma
        JOIN CO_ProgramaImplementaPoliticas PIP ON PI.IdProgramaImplementa = PIP.IdProgramaImplementa
        JOIN CO_ProgramaImplementaElemento PIE ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
        JOIN CO_ProgramaImplementaAcciones PIA ON PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
        LEFT JOIN EN_ContratoEntregableProgramaImplementaAcciones EPIA ON PIA.IdProgramaImplementaAccion = EPIA.IdProgramaImplementaAccion
                                                                         -- AND IdContratoEntregable = @idContratoEntregable 
        WHERE PIT.Id = @IdTipoPrograma
              AND EPIA.idConEntregableProgramaImpAccion IS NULL;
    END;

-- AND EPIA.IdProgramaImplementaAccion IS NULL;

--IF (@MuestraRelacionado = 1)
--BEGIN
--    SELECT CASE
--               WHEN EPIA.idEntregableProgramaImpAccion IS NOT NULL THEN
--                   1
--               ELSE
--                   0
--           END AS Seleccionado,
--           PIT.IdContrato,
--           PIA.IdProgramaImplementaAccion,
--           PI.IdTipoPrograma,
--           PIT.Descripcion AS Programa,
--           PIP.Descripcion AS Politica,
--           PIE.Descripcion AS Elemento,
--           PIA.Descripcion AS Accion
--    FROM CO_ProgramaImplementacionTipo PIT
--    JOIN CO_ProgramaImplementa PI ON PIT.Id = PI.IdTipoPrograma
--                                     AND PIT.Id = @IdTipoPrograma
--    JOIN CO_ProgramaImplementaPoliticas PIP ON PI.IdProgramaImplementa = PIP.IdProgramaImplementa
--    JOIN CO_ProgramaImplementaElemento PIE ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
--    JOIN CO_ProgramaImplementaAcciones PIA ON PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
--    LEFT JOIN EN_EntregableProgramaImplementaAcciones EPIA ON PIA.IdProgramaImplementaAccion = EPIA.IdProgramaImplementaAccion
--    WHERE PIT.Id = @IdTipoPrograma;
--END;
--ELSE
--BEGIN
--    SELECT 0 AS Seleccionado,
--           EPIA.idEntregableProgramaImpAccion,
--           PIT.IdContrato,
--           PIA.IdProgramaImplementaAccion,
--           PI.IdTipoPrograma,
--           PIT.Descripcion AS Programa,
--           PIP.Descripcion AS Politica,
--           PIE.Descripcion AS Elemento,
--           PIA.Descripcion AS Accion
--    FROM CO_ProgramaImplementacionTipo PIT
--    JOIN CO_ProgramaImplementa PI ON PIT.Id = PI.IdTipoPrograma
--                                     AND PIT.Id = @IdTipoPrograma
--    JOIN CO_ProgramaImplementaPoliticas PIP ON PI.IdProgramaImplementa = PIP.IdProgramaImplementa
--    JOIN CO_ProgramaImplementaElemento PIE ON PIE.IdProgramaImplementaPolitica = PIP.IdProgramaImplementaPolitica
--    JOIN CO_ProgramaImplementaAcciones PIA ON PIA.IdProgramaImplementaElemento = PIE.IdProgramaImplementaElemento
--    LEFT JOIN EN_EntregableProgramaImplementaAcciones EPIA ON PIA.IdProgramaImplementaAccion = EPIA.IdProgramaImplementaAccion
--    WHERE PIT.Id = @IdTipoPrograma
--          AND EPIA.IdProgramaImplementaAccion IS NULL;
--END;
END;

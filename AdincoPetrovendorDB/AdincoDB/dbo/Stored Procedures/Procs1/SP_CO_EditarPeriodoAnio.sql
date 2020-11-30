-- =============================================
-- Author:		Marcos Garcia
-- Create date: 2020-02-10
-- Description:	Update 0 = por Perido y 1 = por Año
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_EditarPeriodoAnio] 
-- Add the parameters for the stored procedure here
@IdPCNPorAnio    INT, 
@IdPCNPorPeriodo INT, 
@IdContratoPA    INT, 
@IdEtapa         INT, 
@AniosDuracion   INT, 
@PCNminP         FLOAT, 
@PCNminA         FLOAT, 
@PCNmax          FLOAT, 
@AnioInicio      INT, 
@AnioAsignar     INT, 
@PeriodoAnio     INT, 
@IdUsuario       INT, 
@IdContrato      INT
AS
     BEGIN
         IF(@PeriodoAnio = 0)
             BEGIN
                 UPDATE dbo.CO_PCNPorPeriodos
                   SET 
                       Anios = @AniosDuracion, 
                       PCNPorPeriodoMin = @PCNminP, 
                       PCNPorPeriodoMax = @PCNmax, 
                       AnioInicio = @AnioInicio, 
                       ModificadoPor = @IdUsuario, 
                       ModificadoEn = GETDATE()
                 WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                       AND IdContrato = @IdContratoPA
                       AND IdTipoPgrogramaActividad = @IdEtapa;
             END;
             ELSE
             BEGIN
                 UPDATE dbo.CO_PCNPeriodosPorAnios
                   SET 
                       PCNMinimo = @PCNminA, 
                       Anio = @AnioAsignar, 
                       ModificadoPor = @IdUsuario, 
                       ModificadoEl = GETDATE()
                 WHERE IdPCNPeriodosPorAnios = @IdPCNPorAnio
                       AND IdPCNPorPeriodo = @IdPCNPorPeriodo
             END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;
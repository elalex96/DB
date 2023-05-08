-- =============================================
-- Author:		Marcos Garcia
-- Create date: 2020-02-10
-- Description:	Insert 0 = por Periodo y 1 = por Año
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_AgregarPeriodoAnio] 
-- Add the parameters for the stored procedure here
@IdContratoPA  INT, 
@IdEtapa       INT, 
@AniosDuracion INT, 
@PCNminP       FLOAT, 
@PCNminA       FLOAT, 
@PCNmax        FLOAT, 
@AnioInicio    INT, 
@AnioAsignar   INT, 
@PeriodoAnio   INT, 
@IdUsuario     INT, 
@IdContrato    INT,
@IdPCNPorPeriodo INT
AS
     BEGIN
         IF(@PeriodoAnio = 0)
             BEGIN
                 INSERT INTO dbo.CO_PCNPorPeriodos
                 (IdTipoPgrogramaActividad, 
                  IdContrato, 
                  Anios, 
                  PCNPorPeriodoMin, 
                  PCNPorPeriodoMax, 
                  CreadoPor, 
                  CreadoEn, 
                  ModificadoPor, 
                  ModificadoEn, 
                  AnioInicio
                 )
                 VALUES
                 (@IdEtapa, 
                  @IdContratoPA, 
                  @AniosDuracion, 
                  @PCNminP, 
                  @PCNmax, 
                  @IdUsuario, 
                  GETDATE(), 
                  NULL, 
                  NULL, 
                  @AnioInicio
                 );
                 --====================================
                 DECLARE @idNuevo INT;
                 SET @idNuevo = @@IDENTITY;
                 --====================================
                 INSERT INTO dbo.CO_PCNPeriodosPorAnios
                 (IdPCNPorPeriodo, 
                  Anio, 
                  PCNMinimo, 
                  CreadoPor, 
                  CreadoEn, 
                  ModificadoPor, 
                  ModificadoEl
                 )
                 VALUES
                 (@idNuevo, 
                  @AnioInicio, 
                  @PCNminP, 
                  @IdUsuario, 
                  GETDATE(), 
                  NULL, 
                  NULL
                 );
             END;
             ELSE
             BEGIN                 
                 INSERT INTO dbo.CO_PCNPeriodosPorAnios
                 (IdPCNPorPeriodo, 
                  Anio, 
                  PCNMinimo, 
                  CreadoPor, 
                  CreadoEn, 
                  ModificadoPor, 
                  ModificadoEl
                 )
                 VALUES
                 (@IdPCNPorPeriodo, 
                  @AnioAsignar, 
                  @PCNminA, 
                  @IdUsuario, 
                  GETDATE(), 
                  NULL, 
                  NULL
                 )
             END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;
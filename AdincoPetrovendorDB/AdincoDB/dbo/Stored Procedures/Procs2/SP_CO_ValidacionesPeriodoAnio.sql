-- =============================================
-- Author:		Marcos Garcia
-- Create date: 2020-02-10
-- Description:	Validaciones 
--				0 = Nuevo por Periodo
--				1 = Nuevo por Año
--				2 = Modificar por Periodo
--				3 = Modificar por Año
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ValidacionesPeriodoAnio] 
-- Add the parameters for the stored procedure here
@TipoValidacion  INT, 
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
        IF OBJECT_ID('tempdb..#ValidacionesPA', 'U') IS NOT NULL
            DROP TABLE #ValidacionesPA;
        CREATE TABLE #ValidacionesPA(Validaciones NVARCHAR(MAX));
        --Por Periodo
        IF(@TipoValidacion = 0)
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.CO_PCNPorPeriodos
                    WHERE IdTipoPgrogramaActividad = @IdEtapa
                          AND IdContrato = @IdContratoPA
                )
                    BEGIN
                        INSERT INTO #ValidacionesPA(Validaciones)
                               SELECT 'El Contrato [' + C.NumeroContrato + '] ya cuenta con la Etapa [' + TPA.TipoPrograma + '] registrada.'
                               FROM dbo.CO_Contrato C
                                    JOIN dbo.CO_TipoProgramaActividad TPA ON TPA.IdTipoProgramaActividad = @IdEtapa
                                                                             AND C.IdContrato = @IdContratoPA;
                END;
                    ELSE
                    BEGIN
                        IF(@PCNminP > @PCNmax)
                            BEGIN
                                INSERT INTO #ValidacionesPA(Validaciones)
                            VALUES('El PCN Mínimo no puede ser mayor que PCN Máximo.');
                        END;
                END;
        END;
        --Por Año
        IF(@TipoValidacion = 1)
            BEGIN
                --variables
                DECLARE @anios INT, @cont INT;
                SET @anios =
                (
                    SELECT Anios
                    FROM dbo.CO_PCNPorPeriodos
                    WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                );
                SET @cont =
                (
                    SELECT COUNT(*)
                    FROM dbo.CO_PCNPeriodosPorAnios
                    WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                );
                --
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.CO_PCNPeriodosPorAnios
                    WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                          AND Anio = @AnioAsignar
                )
                    BEGIN
                        INSERT INTO #ValidacionesPA(Validaciones)
                    VALUES('Ya existe un registro para este año [' + CONVERT(NVARCHAR(MAX), @AnioAsignar) + '].');
                END;
                    ELSE
                    BEGIN
                        IF(@cont >= @anios)
                            BEGIN
                                INSERT INTO #ValidacionesPA(Validaciones)
                            VALUES
                                (CASE
                                     WHEN @anios = 1
                                     THEN 'Solo se puede crear 1 registro ya que el periodo dura 1 año.'
                                     ELSE 'Se ha llegado a el máximo de registros permitidos por año de los ' + CONVERT(NVARCHAR(MAX), @anios) + ' años de duración del periodo.'
                                 END
                                );
                        END;
                            ELSE
                            BEGIN
                                IF(@AnioAsignar <
                                (
                                    SELECT AnioInicio
                                    FROM dbo.CO_PCNPorPeriodos
                                    WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                                ))
                                    BEGIN
                                        INSERT INTO #ValidacionesPA(Validaciones)
                                               SELECT 'El año de asignación debe de ser a partir del año [' + CONVERT(NVARCHAR(MAX), AnioInicio) + '] de inicio del periodo.'
                                               FROM dbo.CO_PCNPorPeriodos
                                               WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo;
                                END;
                                    ELSE
                                    BEGIN
                                        INSERT INTO #ValidacionesPA(Validaciones)
                                               SELECT 'PCN Mínimo a asignar a el año [' + CONVERT(NVARCHAR(MAX), @AnioAsignar) + '], debe ser entre PCN Mínimo de ' + CONVERT(NVARCHAR(MAX), PCNP.PCNPorPeriodoMin) + ' y  PCN Máximo de ' + CONVERT(NVARCHAR(MAX), PCNP.PCNPorPeriodoMax) + '.'
                                               FROM dbo.CO_PCNPorPeriodos PCNP
                                               WHERE PCNP.IdPCNPorPeriodo = @IdPCNPorPeriodo
                                                     AND (PCNP.PCNPorPeriodoMin > @PCNminA
                                                          OR PCNP.PCNPorPeriodoMax < @PCNminA);
                                END;
                        END;
                END;
        END;
        --Modificar Por Periodo
        IF(@TipoValidacion = 2)
            BEGIN
                IF(@PCNminP > @PCNmax)
                    BEGIN
                        INSERT INTO #ValidacionesPA(Validaciones)
                    VALUES('El PCN Mínimo no puede ser mayor que PCN Máximo.');
                END;
        END;
        ----Modificar Por Año
        IF(@TipoValidacion = 3)
            BEGIN
                IF(@AnioAsignar <
                (
                    SELECT AnioInicio
                    FROM dbo.CO_PCNPorPeriodos
                    WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                ))
                    BEGIN
                        INSERT INTO #ValidacionesPA(Validaciones)
                               SELECT 'El año de asignación debe de ser a partir del año [' + CONVERT(NVARCHAR(MAX), AnioInicio) + '] de inicio del periodo.'
                               FROM dbo.CO_PCNPorPeriodos
                               WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo;
                END;
                    ELSE
                    BEGIN
                        IF EXISTS
                        (
                            SELECT *
                            FROM dbo.CO_PCNPeriodosPorAnios
                            WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                                  AND Anio = @AnioAsignar
                                  AND IdPCNPeriodosPorAnios <> @IdPCNPorAnio
                        )
                            BEGIN
                                INSERT INTO #ValidacionesPA(Validaciones)
                            VALUES('Ya existe un registro para este año [' + CONVERT(NVARCHAR(MAX), @AnioAsignar) + '].');
                        END;
                            ELSE
                            BEGIN
                                INSERT INTO #ValidacionesPA(Validaciones)
                                       SELECT 'PCN Mínimo a asignar a el año [' + CONVERT(NVARCHAR(MAX), @AnioAsignar) + '], debe ser entre PCN Mínimo de ' + CONVERT(NVARCHAR(MAX), PCNP.PCNPorPeriodoMin) + ' y PCN Máximo de ' + CONVERT(NVARCHAR(MAX), PCNP.PCNPorPeriodoMax) + '.'
                                       FROM dbo.CO_PCNPorPeriodos PCNP
                                       WHERE IdPCNPorPeriodo = @IdPCNPorPeriodo
                                             AND (PCNP.PCNPorPeriodoMin > @PCNminA
                                                  OR PCNP.PCNPorPeriodoMax < @PCNminA);
                        END;
                END;
        END;
        SELECT Validaciones
        FROM #ValidacionesPA;
    END;
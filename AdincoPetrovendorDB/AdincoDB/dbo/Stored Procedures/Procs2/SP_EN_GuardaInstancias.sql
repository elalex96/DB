-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/04/2019
-- Description:	
-- =============================================

CREATE PROCEDURE [dbo].[SP_EN_GuardaInstancias]-- '20191010',3,'20191014',2,2,1,16261,3,10061,12672
    @FechaLimiteint DATE, --10/06/2019
    @DiasElaboracion INT, --3
    @FechaLimiteEntregaRegulador DATE, --14/06/2019
    @DiasRevision INT, --2
    @DiasAprobacion INT, --2
    @DiasAlerta INT, --1
    @IdContratoEntregable INT, --16261
    @idContrato INT, --3
    @idUsuario INT,
    @idEntregable INT --12672
AS
BEGIN
DECLARE 
	--@DiasAlerta INT = 5,
	--@DiasElaboracion INT = 3,
	--@DiasRevision INT = 2,
	--@DiasAprobacion INT = 1,
        @CountFF INT,
        @C INT = 1,
        @CantidadDias INT,
        @FechaInicialSig DATE,@Frecuencia int,@CountDias int;
-----------------------------------------------
IF OBJECT_ID('tempdb..#DiasCE', 'U') IS NOT NULL
    DROP TABLE #DiasCE;
CREATE TABLE #DiasCE
(
    id INT IDENTITY(1, 1),
    dias INT,
    tipo NVARCHAR(15)
);
IF OBJECT_ID('tempdb..#DiasHabiles', 'U') IS NOT NULL
    DROP TABLE #DiasHabiles;
CREATE TABLE #DiasHabiles
(
    Id INT IDENTITY(1, 1),
    IdFecha DATE
);
IF OBJECT_ID('tempdb..#TEMP_InstanciasEntregable', 'U') IS NOT NULL
    DROP TABLE #TEMP_InstanciasEntregable;
CREATE TABLE #TEMP_InstanciasEntregable
(
    Id INT,
    FechasLimiteElaboracion DATETIME,
    FechasLimiteRevision DATETIME,
    FechasLimiteAprobacion DATETIME,
    FechaEnvioMensajeAtrasoRevision DATETIME --,
--  ActividadID INT
);
IF OBJECT_ID('tempdb..#DiasHabilesFrecuencia', 'U') IS NOT NULL
    DROP TABLE #DiasHabilesFrecuencia;
CREATE TABLE #DiasHabilesFrecuencia
(
    Id INT IDENTITY(1, 1),
    IdFecha DATE
);
-----------------------------------------------
    SELECT @Frecuencia =  IdFrecuenciaEntregable
      FROM dbo.EN_Entregable
     WHERE IdEntregable = @idEntregable;

INSERT INTO #DiasHabilesFrecuencia (IdFecha)
Exec [SP_EN_GeneraInstanciasFechasLimite]@FechaLimiteint,@idContrato,@Frecuencia,0,0;

INSERT INTO #DiasCE
( dias, tipo)
VALUES
(@DiasAprobacion, 'Aprobacion'),
(@DiasRevision, 'revision'),
--(@DiasElaboracion, 'Elaboracion'),
(@DiasAlerta, 'Alerta');

SELECT @CountFF =COUNT(*)
FROM #DiasHabilesFrecuencia;
WHILE (@C <= @CountFF) --1<=80
BEGIN
    SET @CantidadDias = 1;
    INSERT INTO #TEMP_InstanciasEntregable
    (
        Id,
        FechasLimiteElaboracion,
        FechasLimiteRevision,
        FechasLimiteAprobacion,
        FechaEnvioMensajeAtrasoRevision -- ,
    -- ActividadID 
    )
    SELECT Id,
           NULL,
           NULL,
           IdFecha,
           NULL
    FROM #DiasHabilesFrecuencia
    WHERE Id = @C;
    SELECT @FechaInicialSig = FechasLimiteAprobacion --2019-10-04 00:00:00.000
    FROM #TEMP_InstanciasEntregable
    WHERE Id = @C;

    SELECT @CountDias = --4
        COUNT(*)
    FROM #DiasCE;
    WHILE (@CantidadDias <= @CountDias) --1<=4
    BEGIN
        ------------------------------------------------
        TRUNCATE TABLE #DiasHabiles;
        INSERT INTO #DiasHabiles
        (
            IdFecha
        )
        SELECT IdFecha
        FROM dbo.AP_Calendario
        WHERE IdFecha < @FechaInicialSig
              AND DATEADD(YEAR, -1, @FechaInicialSig) <= IdFecha
              AND FinDeSemana = 0
              AND DiaLaborable = 1
        ORDER BY IdFecha DESC;

        --Select * from #DiasHabiles
        ------------------------------------------------	 
        --Select @C;
        --Select @CantidadDias;
        UPDATE TIE
        SET FechasLimiteRevision = CASE CE.tipo
                                       WHEN 'Aprobacion' THEN
                                           DH.IdFecha
                                       ELSE
                                           TIE.FechasLimiteRevision
                                   END,
            FechasLimiteElaboracion = CASE CE.tipo
                                          WHEN 'revision' THEN
                                              DH.IdFecha
                                          ELSE
                                              TIE.FechasLimiteElaboracion
                                      END,
            FechaEnvioMensajeAtrasoRevision = CASE CE.tipo
                                                  WHEN 'Alerta' THEN
                                                      DH.IdFecha
                                                  ELSE
                                                      TIE.FechaEnvioMensajeAtrasoRevision
                                              END
        --Select *
        FROM #TEMP_InstanciasEntregable TIE
            LEFT JOIN #DiasCE CE
                ON CE.id = @CantidadDias
            LEFT JOIN #DiasHabiles DH
                ON @FechaInicialSig >= DH.IdFecha
                   AND CE.dias = DH.Id
            LEFT JOIN dbo.AP_Calendario C2
                ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana = 0
                   AND C2.DiaLaborable = 1
        WHERE TIE.Id = @C;

        SELECT @FechaInicialSig = DH.IdFecha
        FROM #TEMP_InstanciasEntregable TIE
            LEFT JOIN #DiasCE CE
                ON CE.id = @CantidadDias
            LEFT JOIN #DiasHabiles DH
                ON @FechaInicialSig >= DH.IdFecha
                   AND CE.dias = DH.Id
            LEFT JOIN dbo.AP_Calendario C2
                ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana = 0
                   AND C2.DiaLaborable = 1
        WHERE TIE.Id = @C;


        SET @CantidadDias = @CantidadDias + 1;
    END;
    SET @C = @C + 1;
END;

SELECT *
FROM #TEMP_InstanciasEntregable;
------------------------------------------------------------------------
END;


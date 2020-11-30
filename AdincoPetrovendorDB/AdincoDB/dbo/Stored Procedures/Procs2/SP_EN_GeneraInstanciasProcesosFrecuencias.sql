-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/04/2019
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_GeneraInstanciasProcesosFrecuencias]
    @FechaLimiteint DATE,
    --  =  '2020-07-18',
    @DiasElaboracion INT,
    -- =3,
    @FechaLimiteEntregaRegulador DATE,
    -- ='2020-07-20',
    @DiasRevision INT,
    -- =2,
    @DiasAprobacion INT,
    -- =  2,
    @DiasAlerta INT,
    -- =  1,
    @IdContratoEntregable INT,
    -- =  16841,
    @idContrato INT,
    -- =  3,
    @idUsuario INT,
    -- =10061,
    @idEntregable INT,
    @Frecuencia INT, 
	@idProcesoInstancia int,
	@idInstanciaEntregable INT               
-- = 10828
AS
BEGIN
    --DECLARE  @FechaLimiteint DATE =  '2020-07-18',
    --    @DiasElaboracion INT =3,
    --    @FechaLimiteEntregaRegulador DATE ='2020-07-18',
    --    @DiasRevision INT =2,
    --    @DiasAprobacion INT =  2,
    --    @DiasAlerta INT =  1,
    --    @IdContratoEntregable INT=  18779,
    --    @idContrato INT =  3,
    --    @idUsuario INT =10061,
    --    @idEntregable INT=13049,
    --	@Frecuencia int=10009       
    DECLARE @CountFF          INT,
            @C                INT = 1,
            @CantidadDias     INT,
            @FechaInicialSig  DATE,
            @CountDias        INT,
            @idActividadElab  INT,
            @idActividadRevi  INT,
            @idActividadAprob INT;
    -----------------------------------------------
  
    CREATE TABLE #DiasCE (id INT IDENTITY(1, 1),
                          dias INT,
                          tipo NVARCHAR(15));

    CREATE TABLE #DiasHabiles (Id INT IDENTITY(1, 1),
                               IdFecha DATE);

    CREATE TABLE #InstanciasEntregable (IdInstanciaEntregable INT,
                                        FechasLimiteAprobacion DATE,
                                        Estatus INT,
                                        TieneArchivo INT);

    CREATE TABLE #TEMP_InstanciasEntregable (Id INT,
                                             FechasLimiteElaboracion DATETIME,
                                             FechasLimiteRevision DATETIME,
                                             FechasLimiteAprobacion DATETIME,
                                             FechaEnvioMensajeAtrasoRevision DATETIME,
                                             FechasLimiteEntregaReg DATETIME,
                                             FechaInicioElaboracion DATETIME);
  
 
    CREATE TABLE #DiasHabilesFrecuencia (Id INT IDENTITY(1, 1),
                                         IdFecha DATE);

    CREATE TABLE #FechasCalcEntregaRegulador (Id INT IDENTITY(1, 1),
                                              IdFecha DATE);
    -----------------------------------------------
    SELECT @idActividadElab = ActividadID
      FROM dbo.EN_Actividad
     WHERE IdContratoEntregable = @IdContratoEntregable --16622
       AND EstadoID             = 10000; --Para elaboración o corrección

    SELECT TOP 1 @idActividadRevi = ActividadID
      FROM dbo.EN_Actividad
     WHERE IdContratoEntregable = @IdContratoEntregable --16622
       AND EstadoID             = 10001; --Para Revisión

    SELECT @idActividadAprob = ActividadID
      FROM dbo.EN_Actividad
     WHERE IdContratoEntregable = @IdContratoEntregable --16622
       AND EstadoID             = 10002; --Para Aprobación

    IF (   @idActividadElab IS NOT NULL
     AND   @idActividadRevi IS NOT NULL
     AND @idActividadAprob IS NOT NULL
     AND   @DiasAlerta IS NOT NULL
     AND   @DiasAlerta > 0 --AND @DiasAprobacion is not null AND @DiasAprobacion>0 
     AND   @DiasRevision IS NOT NULL
     AND   @DiasRevision > 0
     AND   @DiasElaboracion IS NOT NULL
     AND   @DiasElaboracion > 0)
    BEGIN

	IF(@Frecuencia<>0 AND @idProcesoInstancia=0)
	Begin
        INSERT INTO #DiasHabilesFrecuencia (IdFecha)
        EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20190319',3, 10009
            @FechaLimiteint,
            @idContrato,
            @Frecuencia,
			@IdContratoEntregable,
			0,0;

        INSERT INTO #FechasCalcEntregaRegulador (IdFecha)
        EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20190319',3, 10009
            @FechaLimiteEntregaRegulador,
            @idContrato,
            @Frecuencia,
			@IdContratoEntregable,
			0,1;

        INSERT INTO #DiasCE (dias,
                             tipo)
        VALUES
        -- (@DiasAprobacion, 'Aprobacion'),
        (@DiasRevision, 'revision'),
        (@DiasAlerta, 'Alerta');--,
      --  (@DiasElaboracion, 'Elaboracion');

        SELECT @CountFF = COUNT(*)
          FROM #DiasHabilesFrecuencia;

        WHILE (@C <= @CountFF) --1<=80
        BEGIN
            SET @CantidadDias = 1;
            INSERT INTO #TEMP_InstanciasEntregable (Id,
                                                    FechasLimiteElaboracion,
                                                    FechasLimiteRevision,
                                                    FechasLimiteAprobacion,
                                                    FechaEnvioMensajeAtrasoRevision,
                                                    FechasLimiteEntregaReg,
                                                    FechaInicioElaboracion)
            SELECT F.Id,
                   NULL,
                   F.IdFecha,
                   F.IdFecha,
                   NULL,
                   R.IdFecha,
                   NULL
              FROM #DiasHabilesFrecuencia F
              JOIN #FechasCalcEntregaRegulador R
                ON R.Id = F.Id
             WHERE F.Id = @C;

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
                INSERT INTO #DiasHabiles (IdFecha)
                SELECT IdFecha
                  FROM dbo.AP_Calendario
                 WHERE IdFecha                             < @FechaInicialSig
                   AND DATEADD(YEAR, -1, @FechaInicialSig) <= IdFecha
                   AND FinDeSemana                         = 0
                   AND DiaLaborable                        = 1
                 ORDER BY IdFecha DESC;

                ----------------------------------------------------
                UPDATE      TIE
                   SET
                    --FechasLimiteRevision = CASE CE.tipo
                    --                                       WHEN 'Aprobacion' THEN
                    --                                       --    DH.IdFecha
                    --                                       --ELSE
                    --                                           TIE.FechasLimiteRevision
                    --                                   END,
                            FechasLimiteElaboracion = CASE CE.tipo
                                                           WHEN 'revision' THEN DH.IdFecha
                                                           ELSE TIE.FechasLimiteElaboracion END,
                            FechaEnvioMensajeAtrasoRevision = CASE CE.tipo
                                                                   WHEN 'Alerta' THEN DH.IdFecha
                                                                   ELSE TIE.FechaEnvioMensajeAtrasoRevision END--,
                            --FechaInicioElaboracion = CASE CE.tipo
                            --                              WHEN 'Elaboracion' THEN DH.IdFecha
                            --                              ELSE TIE.FechaInicioElaboracion END
                  --Select *
                  FROM      #TEMP_InstanciasEntregable TIE
                  LEFT JOIN #DiasCE CE
                    ON CE.id            = @CantidadDias
                  LEFT JOIN #DiasHabiles DH
                    ON @FechaInicialSig >= DH.IdFecha
                   AND CE.dias          = DH.Id
                  LEFT JOIN dbo.AP_Calendario C2
                    ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha       > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana   = 0
                   AND C2.DiaLaborable  = 1
                 WHERE      TIE.Id = @C;

				 IF((SELECT tipo FROM #DiasCE WHERE id=@CantidadDias)='Alerta')
				 BEGIN 
				 UPDATE TIE
				 SET FechaInicioElaboracion= DH.IdFecha
				       FROM      #TEMP_InstanciasEntregable TIE
                  LEFT JOIN #DiasHabiles DH
                    ON @FechaInicialSig >= DH.IdFecha
                   AND @DiasElaboracion          = DH.Id
                  LEFT JOIN dbo.AP_Calendario C2
                    ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha       > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana   = 0
                   AND C2.DiaLaborable  = 1
                 WHERE      TIE.Id = @C;
				 END
				

                SELECT      @FechaInicialSig = DH.IdFecha
                  FROM      #TEMP_InstanciasEntregable TIE
                  LEFT JOIN #DiasCE CE
                    ON CE.id            = @CantidadDias
                  LEFT JOIN #DiasHabiles DH
                    ON @FechaInicialSig >= DH.IdFecha
                   AND CE.dias          = DH.Id
                  LEFT JOIN dbo.AP_Calendario C2
                    ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha       > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana   = 0
                   AND C2.DiaLaborable  = 1
                 WHERE      TIE.Id = @C;

				
                SET @CantidadDias = @CantidadDias + 1;
            END;
            SET @C = @C + 1;
        END;

        INSERT INTO #InstanciasEntregable (IdInstanciaEntregable,
                                           FechasLimiteAprobacion,
                                           Estatus,
                                           TieneArchivo)
        SELECT      IE.idInstanciaEntregable,
                    IE.FechasLimiteAprobacion,
                    ISNULL(A.EstadoID, 10000),
                    ISNULL(COUNT(ED.DocumentoEntregableId), 0)
          FROM      dbo.EN_InstanciasEntregable IE
          LEFT JOIN dbo.EN_Actividad A
            ON IE.ActividadID           = A.ActividadID
           AND IE.IdContratoEntregable  = A.IdContratoEntregable
          LEFT JOIN EN_EntregableDocumento ED
            ON IE.idInstanciaEntregable = ED.idInstanciaEntregable
         WHERE      IE.IdContratoEntregable = @IdContratoEntregable
         GROUP BY IE.idInstanciaEntregable,
                  IE.FechasLimiteAprobacion,
                  ISNULL(A.EstadoID, 10000);
        --SELECT * FROM #InstanciasEntregable where Estatus<>10000

        DELETE FROM #TEMP_InstanciasEntregable
         WHERE Id IN (   SELECT Id
                           FROM #TEMP_InstanciasEntregable TIE
                           JOIN #InstanciasEntregable IE
                             ON MONTH(TIE.FechasLimiteAprobacion) = MONTH(IE.FechasLimiteAprobacion)
                            AND YEAR(TIE.FechasLimiteAprobacion)  = YEAR(IE.FechasLimiteAprobacion)
                          WHERE Estatus         <> 10000
                             OR IE.TieneArchivo <> 0 );

        DELETE dbo.EN_InstanciasEntregable
         WHERE idInstanciaEntregable IN (   SELECT IdInstanciaEntregable
                                              FROM #InstanciasEntregable
                                          WHERE Estatus      = 10000
                                               AND TieneArchivo = 0 )
           AND IdContratoEntregable = @IdContratoEntregable;

        INSERT INTO dbo.EN_InstanciasEntregable (FechasLimiteElaboracion,
                                                 FechasLimiteRevision,
                                                 FechasLimiteAprobacion,
                                                 FechaEnvioMensajeAtrasoRevision,
                                                 idFrecuencua,
                                                 IdContratoEntregable,
                                                 CorreoEnviado,
                                                 ActividadID,
                                                 CreadoPor,
                                                 CreadoEn,
                                                 ModificadoPor,
                                                 ModificadoEn,
                                                 Activo,
                                                 FechaCalculadaEntregaReg
                                                 ,FechaInicioElaboracion
												 )
        SELECT FechasLimiteElaboracion,
               FechasLimiteRevision,
               FechasLimiteAprobacion,
               FechaEnvioMensajeAtrasoRevision,
               @Frecuencia,
               @IdContratoEntregable,
               0,
               @idActividadElab,
               @idUsuario,
               GETDATE(),
               @idUsuario,
               GETDATE(),
               1,
               FechasLimiteEntregaReg
               ,FechaInicioElaboracion
          FROM #TEMP_InstanciasEntregable ;
     END
	 ----------------------------------------------------------------------------------------------------------------------------------------
	 --Por evento
	 ----------------------------------------------------------------------------------------------------------------------------------------
	 ELSE
     IF(@Frecuencia=0 AND @idProcesoInstancia<>0)
	 BEGIN
	  INSERT INTO #DiasHabilesFrecuencia (IdFecha)
		VALUES (@FechaLimiteint)
     
        INSERT INTO #FechasCalcEntregaRegulador (IdFecha)
        EXEC [SP_EN_GeneraInstanciasFechasLimite] --'20190319',3, 10009
            @FechaLimiteEntregaRegulador,
            @idContrato,
            @Frecuencia,0,1;

        INSERT INTO #DiasCE (dias,
                             tipo)
        VALUES
        -- (@DiasAprobacion, 'Aprobacion'),
        (@DiasRevision, 'revision'),
        (@DiasAlerta, 'Alerta');--,
      --  (@DiasElaboracion, 'Elaboracion');

        SELECT @CountFF = COUNT(*)
          FROM #DiasHabilesFrecuencia;

        WHILE (@C <= @CountFF) --1<=80
        BEGIN
            SET @CantidadDias = 1;
            INSERT INTO #TEMP_InstanciasEntregable (Id,
                                                    FechasLimiteElaboracion,
                                                    FechasLimiteRevision,
                                                    FechasLimiteAprobacion,
                                                    FechaEnvioMensajeAtrasoRevision,
                                                    FechasLimiteEntregaReg,
                                                    FechaInicioElaboracion)
            SELECT F.Id,
                   NULL,
                   F.IdFecha,
                   F.IdFecha,
                   NULL,
                   R.IdFecha,
                   NULL
              FROM #DiasHabilesFrecuencia F
JOIN #FechasCalcEntregaRegulador R
                ON R.Id = F.Id
             WHERE F.Id = @C;

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
                INSERT INTO #DiasHabiles (IdFecha)
                SELECT IdFecha
                  FROM dbo.AP_Calendario
                 WHERE IdFecha                             < @FechaInicialSig
                   AND DATEADD(YEAR, -1, @FechaInicialSig) <= IdFecha
                   AND FinDeSemana                         = 0
                   AND DiaLaborable                        = 1
                 ORDER BY IdFecha DESC;

                ----------------------------------------------------
                UPDATE      TIE
                   SET
                    --FechasLimiteRevision = CASE CE.tipo
                    --                                       WHEN 'Aprobacion' THEN
                    --                                       --    DH.IdFecha
                    --                                       --ELSE
                    --                                           TIE.FechasLimiteRevision
                    --                                   END,
                            FechasLimiteElaboracion = CASE CE.tipo
                                                           WHEN 'revision' THEN DH.IdFecha
                                                           ELSE TIE.FechasLimiteElaboracion END,
                            FechaEnvioMensajeAtrasoRevision = CASE CE.tipo
                                                                   WHEN 'Alerta' THEN DH.IdFecha
                                                                   ELSE TIE.FechaEnvioMensajeAtrasoRevision END--,
                            --FechaInicioElaboracion = CASE CE.tipo
                            --                              WHEN 'Elaboracion' THEN DH.IdFecha
                            --                              ELSE TIE.FechaInicioElaboracion END
                  --Select *
                  FROM      #TEMP_InstanciasEntregable TIE
                  LEFT JOIN #DiasCE CE
                    ON CE.id            = @CantidadDias
                  LEFT JOIN #DiasHabiles DH
                    ON @FechaInicialSig >= DH.IdFecha
                   AND CE.dias          = DH.Id
                  LEFT JOIN dbo.AP_Calendario C2
                    ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha       > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana   = 0
                   AND C2.DiaLaborable  = 1
                 WHERE      TIE.Id = @C;

				 IF((SELECT tipo FROM #DiasCE WHERE id=@CantidadDias)='Alerta')
				 BEGIN 
				 UPDATE TIE
				 SET FechaInicioElaboracion= DH.IdFecha
				       FROM      #TEMP_InstanciasEntregable TIE
                  LEFT JOIN #DiasHabiles DH
                    ON @FechaInicialSig >= DH.IdFecha
                   AND @DiasElaboracion          = DH.Id
                  LEFT JOIN dbo.AP_Calendario C2
                    ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha       > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana   = 0
                   AND C2.DiaLaborable  = 1
                 WHERE      TIE.Id = @C;
				 END
				

                SELECT      @FechaInicialSig = DH.IdFecha
                  FROM      #TEMP_InstanciasEntregable TIE
                  LEFT JOIN #DiasCE CE
                    ON CE.id            = @CantidadDias
                  LEFT JOIN #DiasHabiles DH
ON @FechaInicialSig >= DH.IdFecha
                   AND CE.dias          = DH.Id
                  LEFT JOIN dbo.AP_Calendario C2
                    ON @FechaInicialSig >= C2.IdFecha
                   AND C2.IdFecha       > DATEADD(YEAR, -1, @FechaInicialSig)
                   AND C2.FinDeSemana   = 0
                   AND C2.DiaLaborable  = 1
                 WHERE      TIE.Id = @C;

				
                SET @CantidadDias = @CantidadDias + 1;
            END;
            SET @C = @C + 1;
        END;

        INSERT INTO #InstanciasEntregable (IdInstanciaEntregable,
                                           FechasLimiteAprobacion,
                                           Estatus,
                                           TieneArchivo)
        SELECT      IE.idInstanciaEntregable,
                    IE.FechasLimiteAprobacion,
                    ISNULL(A.EstadoID, 10000),
                    ISNULL(COUNT(ED.DocumentoEntregableId), 0)
          FROM      dbo.EN_InstanciasEntregable IE
          LEFT JOIN dbo.EN_Actividad A
            ON IE.ActividadID           = A.ActividadID
           AND IE.IdContratoEntregable  = A.IdContratoEntregable
          LEFT JOIN EN_EntregableDocumento ED
            ON IE.idInstanciaEntregable = ED.idInstanciaEntregable
         WHERE      IE.IdContratoEntregable = @IdContratoEntregable
         GROUP BY IE.idInstanciaEntregable,
                  IE.FechasLimiteAprobacion,
                  ISNULL(A.EstadoID, 10000);
        --SELECT * FROM #InstanciasEntregable where Estatus<>10000

        DELETE FROM #TEMP_InstanciasEntregable
         WHERE Id IN (   SELECT Id
                           FROM #TEMP_InstanciasEntregable TIE
                           JOIN #InstanciasEntregable IE
                             ON MONTH(TIE.FechasLimiteAprobacion) = MONTH(IE.FechasLimiteAprobacion)
                            AND YEAR(TIE.FechasLimiteAprobacion)  = YEAR(IE.FechasLimiteAprobacion)
                          WHERE Estatus         <> 10000
                             OR IE.TieneArchivo <> 0 );

        DELETE dbo.EN_InstanciasEntregable
         WHERE idInstanciaEntregable IN (   SELECT IdInstanciaEntregable
                                              FROM #InstanciasEntregable
                                             WHERE Estatus      = 10000
                                               AND TieneArchivo = 0 )
           AND IdContratoEntregable = @IdContratoEntregable;

        INSERT INTO dbo.EN_InstanciasEntregable (FechasLimiteElaboracion,
                                                 FechasLimiteRevision,
                                                 FechasLimiteAprobacion,
                                                 FechaEnvioMensajeAtrasoRevision,
                                                 idFrecuencua,
                                                 IdContratoEntregable,
                                                 CorreoEnviado,
                                                 ActividadID,
                                                 CreadoPor,
                                                 CreadoEn,
                                                 ModificadoPor,
                                                 ModificadoEn,
                                                 Activo,
                                                 FechaCalculadaEntregaReg
                                                 ,FechaInicioElaboracion
												 )
        SELECT FechasLimiteElaboracion,
               FechasLimiteRevision,
               FechasLimiteAprobacion,
               FechaEnvioMensajeAtrasoRevision,
               @Frecuencia,
               @IdContratoEntregable,
               0,
               @idActividadElab,
               @idUsuario,
               GETDATE(),
               @idUsuario,
               GETDATE(),
               1,
               FechasLimiteEntregaReg
               ,FechaInicioElaboracion
          FROM #TEMP_InstanciasEntregable ;
     END
    END;
    ELSE
    BEGIN
        SELECT 'Guarde usuarios responsables del entregable, los días de elaboración, revisión, aprobación y alerta deben ser mayor a 0' AS error;
    END;

------------------------------------------------------------------------
END;



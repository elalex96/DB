-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Guarda Elaboradores
-- =============================================

CREATE PROCEDURE [dbo].[sp_EN_GeneraFlujoContratoEntregable]--16904,10061,3-- 16841,10061,3
    @IdContratoEntregable INT,
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#TempFlujo') IS NOT NULL
        DROP TABLE #TempFlujo;

    CREATE TABLE #TempFlujo (idFlujo INT IDENTITY(1, 1),
                             ActividadInicialID INT,
                             AccionID INT,
                             SiguienteActividadID INT,
                             IdContratoEntregable INT,
                             CreadoPor INT,
                             CreadoEn DATETIME,
                             ModificadoPor INT,
                             ModificadoEn DATETIME,
                             Activo BIT);
    ---------------------------------------------------
    IF OBJECT_ID('tempdb..#TempRevisores') IS NOT NULL
        DROP TABLE #TempRevisores;

    CREATE TABLE #TempRevisores (IDRevisor INT IDENTITY(2, 2),
                                 ActividadID INT,
                                 EstadoID INT,
                                 idUsuario INT,
                                 IdContratoEntregable INT);
    IF OBJECT_ID('tempdb..#TempRevisores') IS NOT NULL
        IF OBJECT_ID('tempdb..#TempAsignaSiguienteAct') IS NOT NULL
            DROP TABLE #TempAsignaSiguienteAct;

    CREATE TABLE #TempAsignaSiguienteAct (idActiviSigui INT IDENTITY(2, 2),
                                          ActividadInicialID INT,
                                          AccionID INT,
                                          SiguienteActividadID INT,
                                          IdContratoEntregable INT);
    -------------------------------------------------
    --SELECT * FROM EN_Accion
    --SELECT * FROM dbo.EN_Actividad;
    --SELECT * FROM EN_transicion
    DECLARE @idActividadInicial       INT,
            @idActividadFinal         INT,
            @Count                    INT,
            @idActividadElaboracion   INT,
            @idActividadUltimoRevisor INT;

    SELECT @Count = COUNT(ActividadID)
      FROM EN_Actividad
     WHERE @IdContratoEntregable = @IdContratoEntregable
	 AND Activo=1;
    IF @Count >= 3 -- Que contenga un elaborador, revisor y aprobador final
    BEGIN
        SELECT TOP 1 @idActividadFinal = ActividadID --PRIMER Revisor
          FROM En_ACTIVIDAD
         WHERE EstadoId             = 10001
           AND IdContratoEntregable = @IdContratoEntregable
		   AND Activo=1
         ORDER BY CreadoEN ASC;

        SELECT TOP 1 @idActividadUltimoRevisor = --ULTIMO Revisor
            ActividadID
          FROM En_ACTIVIDAD
         WHERE EstadoId             = 10001
           AND IdContratoEntregable = @IdContratoEntregable
		   AND Activo=1
         ORDER BY CreadoEN DESC;

        INSERT INTO #TempFlujo (ActividadInicialID, --Inserta Seccion Elaboracion
                                AccionID,
                                SiguienteActividadID,
                                IdContratoEntregable,
                                CreadoPor,
                                CreadoEn,
                                ModificadoPor,
                                ModificadoEn,
                                Activo)
        SELECT ActividadID,
               10000 AS AccionID,
               @idActividadFinal AS ActividadFinal,
               @IdContratoEntregable,
               @idUsuario,
               CreadoEn,
               @idUsuario,
               CreadoEn,
               1
          FROM En_ACTIVIDAD
         WHERE EstadoId             = 10000
           AND IdContratoEntregable = @IdContratoEntregable
		   AND Activo=1; --Elaboracion

        INSERT INTO #TempFlujo (ActividadInicialID, --Inserta Seccion de revisores y el ultimo aprobador que subira el acuse
                                AccionID,
                                SiguienteActividadID,
                                IdContratoEntregable,
                                CreadoPor,
                                CreadoEn,
                                ModificadoPor,
                                ModificadoEn,
                                Activo)
        SELECT      A.ActividadID,
                    ACC.AccionID,
                    CASE AccionID
                         WHEN 10002 THEN Activi.ActividadID
                         ELSE 0 END AS 'ActividadSiguiente',
                    @IdContratoEntregable,
                    @idUsuario,
                    A.CreadoEn,
                    @idUsuario,
                    A.CreadoEn,
                    1
          FROM      En_ACTIVIDAD A
          LEFT JOIN EN_Accion ACC
            ON ACC.AccionID                <> 10000 AND ACC.Activo = 1
          LEFT JOIN En_ACTIVIDAD Activi
            ON Activi.EstadoID             = 10000
           AND Activi.IdContratoEntregable = @IdContratoEntregable
		    AND Activi.Activo = 1
         WHERE      A.EstadoId NOT IN ( 10000, 10004 )
           AND      A.IdContratoEntregable = @IdContratoEntregable
		   AND A.Activo = 1
         ORDER BY A.ModificadoEN ASC;

        DELETE tf
          --SELECT * 
          FROM #TempFlujo tf
          JOIN En_ACTIVIDAD A
            ON tf.ActividadInicialID = A.ActividadID
         WHERE EstadoID    = 10003
           AND tf.AccionID = 10001 
		   AND A.Activo=1;

        UPDATE tf
           SET SiguienteActividadID = CASE A.EstadoID
                                           WHEN 10002 THEN CASE tf.AccionID
                                                                WHEN 10001 THEN APF.ActividadID
                                                                ELSE tf.SiguienteActividadID END
                                           ELSE tf.SiguienteActividadID END
          FROM #TempFlujo tf
          JOIN EN_Actividad A
            ON tf.ActividadInicialID    = A.ActividadID
           AND A.IdContratoEntregable   = @IdContratoEntregable
		    AND A.Activo=1
          JOIN EN_Actividad APF
            ON APF.EstadoID             = 10003
           AND APF.IdContratoEntregable = @IdContratoEntregable
		    AND APF.Activo=1;;

        UPDATE tf
           SET SiguienteActividadID = CASE tf.ActividadInicialID
                                           WHEN @idActividadUltimoRevisor THEN CASE tf.AccionID
                                                                                    WHEN 10001 THEN APF.ActividadID
                                                                                    ELSE tf.SiguienteActividadID END
                                           ELSE tf.SiguienteActividadID END
          FROM #TempFlujo tf
          JOIN EN_Actividad A
            ON tf.ActividadInicialID    = A.ActividadID
           AND A.IdContratoEntregable   = @IdContratoEntregable
		   AND A.Activo=1
          JOIN EN_Actividad APF
            ON APF.EstadoID             = 10002
           AND APF.IdContratoEntregable = @IdContratoEntregable
		   AND  APF.Activo=1;

        --SELECT *
        --FROM #TempFlujo
        --ORDER BY ModificadoEn ASC;

        -------------------------------------------------------

        INSERT INTO #TempRevisores (ActividadID,
                                    EstadoID,
                                    idUsuario,
                                    IdContratoEntregable)
        SELECT ActividadID,
               EstadoID,
               idUsuario,
               IdContratoEntregable
          FROM En_ACTIVIDAD A
         WHERE A.EstadoId             = 10001
           AND A.IdContratoEntregable = @IdContratoEntregable
		   AND A.Activo=1
         ORDER BY A.ModificadoEN ASC;

        ----------------------------------------------------------------------
        INSERT INTO #TempAsignaSiguienteAct (ActividadInicialID,
                                             AccionID,
 SiguienteActividadID,
                                             IdContratoEntregable)
        SELECT      ActividadInicialID,
                    AccionID,
                    MIN(ActividadID),
                    #TempFlujo.IdContratoEntregable
          FROM      #TempFlujo
         RIGHT JOIN #TempRevisores
            ON #TempRevisores.IdContratoEntregable = #TempFlujo.IdContratoEntregable
           AND ActividadInicialID                  < ActividadID
         WHERE      SiguienteActividadID = 0
         GROUP BY ActividadInicialID,
                  AccionID,
                  #TempFlujo.IdContratoEntregable
         ORDER BY ActividadInicialID ASC;

        --SELECT 	* FROM #TempAsignaSiguienteAct
        UPDATE tf
           SET SiguienteActividadID = CASE tf.AccionID
                                           WHEN 10001 THEN CASE tf.SiguienteActividadID
                                                                WHEN 0 THEN ta.SiguienteActividadID
                                                                ELSE tf.SiguienteActividadID END
                                           ELSE tf.SiguienteActividadID END
          FROM #TempFlujo tf
          JOIN #TempAsignaSiguienteAct ta
            ON tf.ActividadInicialID = ta.ActividadInicialID
         WHERE tf.SiguienteActividadID = 0;

		 DELETE EN_Transicion WHERE IdContratoEntregable=@IdContratoEntregable

        INSERT INTO EN_Transicion (ActividadInicialID,
                                   AccionID,
                                   SiguienteActividadID,
                                   IdContratoEntregable,
                                   CreadoPor,
                                   CreadoEn,
                                   ModificadoPor,
                                   ModificadoEn,
                                   Activo)
        SELECT ActividadInicialID,
                                   AccionID,
                                   SiguienteActividadID,
                                   IdContratoEntregable,
                                   CreadoPor,
                                   CreadoEn,
                                   ModificadoPor,
                                   ModificadoEn,
                                   Activo
          FROM #TempFlujo;

		 	  IF @@ERROR <> 0
        SELECT ERROR_MESSAGE() AS error
    ELSE
		SELECT '' AS error
    END;
END;


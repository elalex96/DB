
CREATE PROCEDURE [dbo].[EN_SqlResponsablesContratoEntregable] -- 16841,10061,3,10002,10001
    @IdContratoEntregable INT,
    @idUsuarioSession INT,
    @idContrato INT,
    @idUsuario INT, --Responsable
    @idEstatus INT
AS
BEGIN
    SET NOCOUNT ON;

    IF OBJECT_ID('tempdb..#InstanciasEstatus') IS NOT NULL
        DROP TABLE #InstanciasEstatus;

    CREATE TABLE #InstanciasEstatus
    (
        idInstancia INT,
        EstadoID INT
    );

    IF OBJECT_ID('tempdb..#InstanciasEstatusRevision') IS NOT NULL
        DROP TABLE #InstanciasEstatusRevision;

    CREATE TABLE #InstanciasEstatusRevision
    (
        idInstancia INT,
        EstadoID INT
    );

    DECLARE @CountInstRevAprob INT,
            @Error NVARCHAR(MAX),
            @PrimerRevisor INT;


    SELECT @CountInstRevAprob = COUNT(*)
    FROM dbo.EN_InstanciasEntregable ie
    JOIN dbo.EN_Actividad a ON a.ActividadID = ie.ActividadID
                               AND a.IdContratoEntregable = ie.IdContratoEntregable
                               AND EstadoID IN ( 10001, 10002 )
    WHERE ie.IdContratoEntregable = @IdContratoEntregable; --Cuenta las instancias pendientes

    INSERT INTO #InstanciasEstatus (idInstancia, EstadoID)
    SELECT ie.idInstanciaEntregable,
           a.EstadoID
    FROM dbo.EN_InstanciasEntregable ie
    JOIN dbo.EN_Actividad a ON a.ActividadID = ie.ActividadID
                               AND a.IdContratoEntregable = ie.IdContratoEntregable
                               AND EstadoID NOT IN ( 10001 )
    WHERE ie.IdContratoEntregable = @IdContratoEntregable; --Guarda las instancias con En elaboración, En aprobación y completamente aprobado

    --------------------------------------------------Especial para instancias pendientes
    INSERT INTO #InstanciasEstatusRevision (idInstancia, EstadoID)
    SELECT ie.idInstanciaEntregable,
           a.EstadoID
    FROM dbo.EN_InstanciasEntregable ie
    JOIN dbo.EN_Actividad a ON a.ActividadID = ie.ActividadID
                               AND a.IdContratoEntregable = ie.IdContratoEntregable
                               AND EstadoID IN ( 10001 )
    WHERE ie.IdContratoEntregable = @IdContratoEntregable;

    --------------------------------------------------------------------------
	--print 1

	DELETE FROM dbo.EN_ExcepcionesActividad
		WHERE IdInstanciasEntregables IN
        (
            SELECT idInstancia FROM #InstanciasEstatus
			UNION 
			SELECT idInstancia FROM #InstanciasEstatusRevision
        );

	--print 2

	DELETE dbo.EN_Transicion
    WHERE SiguienteActividadID IN
          (
              SELECT ActividadID
              FROM dbo.EN_Actividad
				WHERE EstadoID = @idEstatus
				AND IdContratoEntregable = @IdContratoEntregable
				AND Activo = 0
          )
          OR ActividadInicialID IN
             (
                SELECT ActividadID
                FROM dbo.EN_Actividad
					WHERE EstadoID = @idEstatus
					AND IdContratoEntregable = @IdContratoEntregable
					AND Activo = 0
             );

	--print 3
	DELETE FROM dbo.EN_URLResponsablesEntregables
    WHERE ActividadID IN
          (
              SELECT ActividadID
              FROM dbo.EN_Actividad
              WHERE EstadoID = @idEstatus
                    AND IdContratoEntregable = @IdContratoEntregable
                    AND Activo = 0
          );

	--print 4
    DELETE FROM dbo.EN_Actividad
    WHERE EstadoID = @idEstatus
    AND IdContratoEntregable = @IdContratoEntregable
    AND Activo = 0;
  
    IF (@idEstatus IN ( 10000, 10002, 10003 ))
    BEGIN
        UPDATE dbo.EN_Actividad
        SET Activo = 0
        WHERE EstadoID = @idEstatus
              AND IdContratoEntregable = @IdContratoEntregable;
    END;
	--print 4.1
	--select		EstadoID=@idEstatus, idUsuario = @idUsuario, IdContratoEntregable=@IdContratoEntregable,       CreadoPor=@idUsuarioSession,	 CreadoEn=GETDATE(), ModificadoPor=@idUsuarioSession,   ModificadoEn=GETDATE(), Activo=1
	--select	EstadoID,    idUsuario,   IdContratoEntregable, CreadoPor,   CreadoEn,  ModificadoPor, ModificadoEn, Activo
	--from	EN_Actividad 
	--where	EstadoID =@idEstatus 
	--and		idUsuario = @idUsuario
	
    INSERT INTO EN_Actividad (EstadoID, idUsuario, IdContratoEntregable,       CreadoPor,	 CreadoEn, ModificadoPor,   ModificadoEn, Activo)
    VALUES					(@idEstatus, @idUsuario, @IdContratoEntregable, @idUsuarioSession, GETDATE(), @idUsuarioSession, GETDATE(), 1);
    
	--			modifica las instancias en pendiente de aprobación, en elaboración y aprobados completamente
	--print 4.2
    UPDATE IE
    SET IE.ActividadID = A.ActividadID
    FROM dbo.EN_Actividad A
    JOIN #InstanciasEstatus IET ON A.EstadoID = IET.EstadoID
                                   AND A.Activo = 1
    JOIN dbo.EN_InstanciasEntregable IE ON IET.idInstancia = IE.idInstanciaEntregable
                                           AND IE.IdContratoEntregable = A.IdContratoEntregable
    WHERE IE.idInstanciaEntregable IN
          (
              SELECT idInstancia FROM #InstanciasEstatus
          );
    --------------------------------------------------------------------------------------------
    -------------------------modifica las instancias en pendiente de revisión
    SELECT TOP 1
           @PrimerRevisor = ActividadID --PRIMER Revisor
    FROM EN_Actividad
    WHERE EstadoID = 10001
          AND Activo = 1
          AND IdContratoEntregable = @IdContratoEntregable
    ORDER BY CreadoEn ASC;

    UPDATE IE
    SET IE.ActividadID = @PrimerRevisor
    FROM dbo.EN_InstanciasEntregable IE
    WHERE IE.idInstanciaEntregable IN
          (
              SELECT idInstancia FROM #InstanciasEstatusRevision
          );
    ---------------------------------------------------------------------------------------------
	--print 5
    DELETE FROM dbo.EN_ExcepcionesActividad
    WHERE IdInstanciasEntregables IN
          (
              SELECT idInstancia FROM #InstanciasEstatus
			  UNION 
			  SELECT idInstancia FROM #InstanciasEstatusRevision
          );
	--print 6
    DELETE dbo.EN_Transicion
    WHERE SiguienteActividadID IN
          (
              SELECT ActividadID
              FROM dbo.EN_Actividad
              WHERE EstadoID = @idEstatus
                    AND IdContratoEntregable = @IdContratoEntregable
                    AND Activo = 0
          )
          OR ActividadInicialID IN
             (
                 SELECT ActividadID
                 FROM dbo.EN_Actividad
                 WHERE EstadoID = @idEstatus
                       AND IdContratoEntregable = @IdContratoEntregable
                       AND Activo = 0
             );
	--print 7
    DELETE FROM dbo.EN_URLResponsablesEntregables
    WHERE ActividadID IN
          (
              SELECT ActividadID
              FROM dbo.EN_Actividad
              WHERE EstadoID = @idEstatus
                    AND IdContratoEntregable = @IdContratoEntregable
                    AND Activo = 0
          );

	--print 8
    DELETE FROM dbo.EN_Actividad
    WHERE EstadoID = @idEstatus
          AND IdContratoEntregable = @IdContratoEntregable
          AND Activo = 0;

    IF @@ERROR <> 0
        SELECT @Error = @Error + ERROR_MESSAGE();
  
    SET @Error = N'NOHAYERROR: Existen ' + LTRIM(@CountInstRevAprob)+ N' entregables Pendientes de Revisar/Aprobar a los cuales se aplicó el mismo cambio.';
    SELECT @Error AS error;

END;


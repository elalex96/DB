-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Elimina Procesos de Macroproceso
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 29/10/2021
-- Description:	Se agrega a la bitacora EN_Bitacora_EntregablesModificados
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_DeleteRevisorcontratoEntregable] --16623,10061,2,3
    @IdContratoEntregable INT,
    @idUsuarioSession INT,
    @idUsuario INT,
    @idContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#InstanciasEstatusRevision') IS NOT NULL
        DROP TABLE #InstanciasEstatusRevision;

    CREATE TABLE #InstanciasEstatusRevision
    (
        idInstancia INT,
        EstadoID INT
    );

    DECLARE @CountInstRevAprob INT,
            @Error NVARCHAR(MAX) = N'',
            @PrimerRevisor INT = 0;

    SELECT @CountInstRevAprob = COUNT(*)
    FROM dbo.EN_InstanciasEntregable ie
        JOIN dbo.EN_Actividad a
            ON a.ActividadID = ie.ActividadID
               AND a.IdContratoEntregable = ie.IdContratoEntregable
               AND EstadoID IN ( 10001, 10002 )
    WHERE ie.IdContratoEntregable = @IdContratoEntregable;
    -- SELECT @CountInstRevAprob;

    -------------------------------------------------------------------------------
    --------------------------------------------------Especial para instancias pendientes de rvisión
    INSERT INTO #InstanciasEstatusRevision (idInstancia, EstadoID)
    SELECT ie.idInstanciaEntregable,
           a.EstadoID
    FROM dbo.EN_InstanciasEntregable ie
        JOIN dbo.EN_Actividad a
            ON a.ActividadID = ie.ActividadID
               AND a.IdContratoEntregable = ie.IdContratoEntregable
               AND EstadoID IN ( 10001 )
    WHERE ie.IdContratoEntregable = @IdContratoEntregable;
    ----------------------------------------------------------------------------------------------------
    UPDATE dbo.EN_Actividad
    SET Activo = 0
    WHERE EstadoID = 10001
          AND idUsuario = @idUsuario
          AND IdContratoEntregable = @IdContratoEntregable;
    --************************************************************
    --DECLARE @PrimerRevisor INT=0;
    SELECT TOP 1
           @PrimerRevisor = ActividadID --PRIMER Revisor
    FROM EN_Actividad
    WHERE EstadoID = 10001
          AND Activo = 1
          AND IdContratoEntregable = @IdContratoEntregable
    ORDER BY CreadoEn ASC;
    --SELECT @PrimerRevisor
    IF (@PrimerRevisor <> 0) --Si tiene 1 revisor se pone las intancias al primer revisor, si no (si se elimina el unico revisor) solo se desactiva la actividad y será borrada la actividad con activo 0 hasta que tenga un revisor 
    BEGIN
        UPDATE IE
        SET IE.ActividadID = @PrimerRevisor
        FROM dbo.EN_InstanciasEntregable IE
        WHERE IE.idInstanciaEntregable IN
              (
                  SELECT idInstancia FROM #InstanciasEstatusRevision
              );
        --************************************************************
        DELETE FROM dbo.EN_ExcepcionesActividad
        WHERE IdInstanciasEntregables IN
              (
                  SELECT idInstancia FROM #InstanciasEstatusRevision
              );

        DELETE dbo.EN_Transicion
        WHERE SiguienteActividadID IN
              (
                  SELECT ActividadID
                  FROM dbo.EN_Actividad
                  WHERE EstadoID = 10001
                        AND IdContratoEntregable = @IdContratoEntregable
                        AND Activo = 0
              )
              OR ActividadInicialID IN
                 (
                     SELECT ActividadID
                     FROM dbo.EN_Actividad
                     WHERE EstadoID = 10001
                           AND IdContratoEntregable = @IdContratoEntregable
                           AND Activo = 0
                 );

        DELETE FROM dbo.EN_URLResponsablesEntregables
        WHERE ActividadID IN
              (
                  SELECT ActividadID
         FROM dbo.EN_Actividad
                  WHERE EstadoID = 10001
                        AND IdContratoEntregable = @IdContratoEntregable
                        AND Activo = 0
              );

        DELETE FROM dbo.EN_Actividad
        WHERE EstadoID = 10001
              AND IdContratoEntregable = @IdContratoEntregable
              AND Activo = 0;
    END;
    SET @Error = N'';

	INSERT INTO EN_Bitacora_EntregablesModificados(	
		IdContrato,				IdEntregable,RevisorAnterior,					
		ModificadoPor,			ModificadoEl) VALUES
		(@IdContrato,			@IdContratoEntregable,@idUsuario,
		@idUsuarioSession,		GETDATE())

    SELECT @Error AS error;
END;

--Select * from dbo.EN_Actividad WHERE IdContratoEntregable=17656
--Select * from  dbo.EN_InstanciasEntregable WHERE idInstanciaEntregable=257705
--SELECT * FROM dbo.AP_Usuario WHERE UsuarioID=12
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019/02/14
-- Description:Elimina Procesos de Macroproceso
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_DeleteRevisorContratoEntregableUnico] --16623,10061,2,3
    @IdContratoEntregable INT,
    @idUsuarioSession INT,
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
          AND IdContratoEntregable = @IdContratoEntregable;
    --************************************************************
	
    SET @Error = N'';

    SELECT @Error AS error;
END;

--Select * from dbo.EN_Actividad WHERE IdContratoEntregable=17656
--Select * from  dbo.EN_InstanciasEntregable WHERE idInstanciaEntregable=257705


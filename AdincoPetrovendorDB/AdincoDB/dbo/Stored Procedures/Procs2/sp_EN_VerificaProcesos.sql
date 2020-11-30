-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_VerificaProcesos]
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @idActividades        INT,
            @instanciaPocesos     INT,
            @instanciaActividades INT,
            @instanciaEntregables INT;

    SELECT @idActividades = COUNT(*)
      FROM dbo.EN_ProcesosActividades
     WHERE IdProceso = @idProceso;

    SELECT @instanciaPocesos = COUNT(*)
      FROM dbo.EN_InstanciasProcesosFecha
     WHERE IdProceso = @idProceso;

    SELECT @instanciaActividades = COUNT(*)
      FROM dbo.EN_InstanciasActividades
     WHERE IdInstanciasProcesos = @instanciaPocesos;

    SELECT @instanciaEntregables = COUNT(*)
      FROM dbo.EN_InstanciasEntregable IE
      JOIN dbo.EN_InstanciasEntregables_InstanciaActividad IET
        ON IE.idInstanciaEntregable = IET.idInstanciaEntregable
      JOIN dbo.EN_InstanciasActividades IA
        ON IET.idInstanciaActividad = IA.idInstanciaActividad
     WHERE IdInstanciasProcesos = @instanciaPocesos;

    IF (   @instanciaPocesos = 0
     AND   @instanciaActividades = 0
     AND   @instanciaEntregables = 0)
    BEGIN
      SELECT 0
    END;
    ELSE
    BEGIN
        SELECT 1
    END;

END;



-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Llama las rondas
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_EliminaProcesos]
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @idActividades        INT,
            @instanciaPocesos     INT,
            @instanciaActividades INT,
            @instanciaEntregables INT, @Macroproceso int;

    SELECT @idActividades = COUNT(1)
      FROM dbo.EN_ProcesosActividades
     WHERE IdProceso = @idProceso;

    SELECT @instanciaPocesos = COUNT(1)
      FROM dbo.EN_InstanciasProcesosFecha
     WHERE IdProceso = @idProceso;

    SELECT @instanciaActividades = COUNT(1)
      FROM dbo.EN_InstanciasActividades
     WHERE IdInstanciasProcesos = @instanciaPocesos;

    SELECT @instanciaEntregables = COUNT(1)
      FROM dbo.EN_InstanciasEntregable IE
      JOIN dbo.EN_InstanciasEntregables_InstanciaActividad IET
        ON IE.idInstanciaEntregable = IET.idInstanciaEntregable
      JOIN dbo.EN_InstanciasActividades IA
        ON IET.idInstanciaActividad = IA.idInstanciaActividad
     WHERE IdInstanciasProcesos = @instanciaPocesos;

	 SELECT @Macroproceso=COUNT(1)
	 FROM dbo.EN_MacroProcesosRelacion WHERE idProcesoHijo IN (@idProceso)

    IF (  @instanciaPocesos = 0
     AND   @instanciaActividades = 0
     AND   @instanciaEntregables = 0 
	 AND @Macroproceso=0)
    BEGIN

        DELETE FROM dbo.EN_ProcesosContrato
         WHERE idContrato = @idContrato
           AND idProceso  = @idProceso;

        DELETE FROM dbo.EN_ProcesosRondas
         WHERE IdProceso = @idProceso;
    
		DELETE FROM dbo.EN_ProcesosActividades
         WHERE IdProceso = @idProceso;

		DELETE FROM EN_Procesos WHERE IdProceso=@idProceso
    
    END;
    ELSE
    BEGIN
       SELECT 'Este proceso ya contiene fechas calculadas o se encuentra en un Macroproceso, no se puede eliminar';
    END;

END;


-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 06-04-2017
-- Description:	 SP que reasigna una tarea a otra aprobador
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ReasignarAprobadorPedido] 
	-- Add the parameters for the stored procedure here
	@IdOperacion int, 
	@IdAprobador int, 
	@IdNuevoAprobador int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	 DECLARE @IdTareaActual int 
	 DECLARE @IdTareaNueva int  
	 DECLARE @Descripcion nvarchar(max)


	 SET NOCOUNT ON;
	 --- Obtener el IdTarea de la Tarea del Usuario Actual----

	    SET @IdTareaActual = (SELECT T.IdTarea
							   FROM TA_Tarea AS T
							   INNER JOIN TA_Operacion AS TOO ON TOO.IdOperacion = T.IdOperacion
							   WHERE TOO.IdOperacion = @IdOperacion AND T.IdAprobador = @IdAprobador)

	 --- Agregar Tarea Usuario Nuevo --- 
	
		 INSERT INTO TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion)
		 SELECT NombreTarea,GETDATE() AS FechaRegistro,IdEstatus,Activo, Visto,@IdNuevoAprobador AS IdAprobador,NoSecuencia,IdOperacion
		 FROM TA_Tarea AS T
		 WHERE T.IdTarea =  @IdTareaActual

		SET @IdTareaNueva = (SELECT @@IDENTITY)
	

	--- Cambiar Activo Aprobador Actual ---
	--- IdEstatus 7 --> Cancelado por reasignación

		 UPDATE TA_TAREA  SET Activo  = 0, IdEstatus = 7
		 WHERE IdTarea = @IdTareaActual

	 --- Agregar Evento Historial --- 

		 SET @Descripcion = 'El usuario '+
							(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdAprobador)+ 
							' ha reasignado la tarea al usuario ' +
							(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdNuevoAprobador) 
							
		 INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
		 VALUES(@Descripcion,@IdOperacion,GETDATE(),8)
    
	--- Enviar Datos del Nuevo Aprobador ---

		   SELECT Nombre, Correo
		   FROM S_Usuario
		   WHERE IdUsuario = @IdNuevoAprobador
    
 END



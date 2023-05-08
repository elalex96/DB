-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 12-04-2020
-- Description:	 Se retorna la información de la nueva tarea
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
	 DECLARE @NoSecuencia INT 
	 DECLARE @Descripcion nvarchar(max)


	 SET NOCOUNT ON;
	 --- Obtener el IdTarea de la Tarea del Usuario Actual----

	    SELECT @IdTareaActual= T.IdTarea		
		FROM TA_Tarea AS T
		JOIN TA_Operacion AS TOO 
		ON T.IdOperacion = TOO.IdOperacion
		WHERE TOO.IdOperacion = @IdOperacion 
		AND T.IdAprobador = @IdAprobador
		AND T.Activo=1 -->CTE 

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

		 SELECT 
		 @NoSecuencia =NoSecuencia
		 FROM TA_Tarea WHERE IdTarea=@IdTareaNueva
    
	--- Enviar Datos del Nuevo Aprobador ---

		SELECT Nombre, Correo,@IdTareaNueva,@NoSecuencia
		FROM S_Usuario
		WHERE IdUsuario = @IdNuevoAprobador
    
 END



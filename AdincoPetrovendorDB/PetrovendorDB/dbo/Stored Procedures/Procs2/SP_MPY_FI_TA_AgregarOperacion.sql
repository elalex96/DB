-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Permite agregar LA OPERACION para hacer relacion con un flujo de tareas
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_MPY_FI_TA_AgregarOperacion] 
	-- Add the parameters for the stored procedure here
		
	@IdDocumento int,
	@IdProveedor int,
	@IdAsignador int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DescripcionH nvarchar(MAX)
	DECLARE @IdOperacion int

	
	
    -- Agregar Operación Si IdFlujoTarea =  0 Es una operación que no tiene flujo de tarea

			INSERT INTO TA_Operacion(IdDocumento,IdTipoOperacion,IdFlujoTarea,IdEstatusOperacion,IdEstadoFlujo,IdProveedor,IdAsignador,FechaRegistro,Descripcion, IdVigencia, IdPrioridad)
			VALUES(@IdDocumento,10,NULL,1,NULL,@IdProveedor,NULL,GETDATE(),'',NULL,NULL)


	SET @IdOperacion = (SELECT @@IDENTITY)

	

	----Agregar Evento al Historial del Flujo de Tarea----

	SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdAsignador)+ ' ha registrado la Tarea de Tipo ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion=10)

	INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
	VALUES(@IdOperacion,GETDATE(),@DescripcionH,1)

	SELECT @IdOperacion AS IdOperacion

END

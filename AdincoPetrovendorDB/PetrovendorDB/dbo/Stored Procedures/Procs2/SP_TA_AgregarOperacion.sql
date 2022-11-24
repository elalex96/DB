/****** Object:  StoredProcedure [dbo].[SP_TA_AgregarOperacion]    Script Date: 29/09/2020 13:06:19 ******/
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Permite agregar LA OPERACION para hacer relacion con un flujo de tareas
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/10/2019
-- Description:	se valida que no exista la operacion con los datos(evita duplicidad en las operaciones)
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_AgregarOperacion] 
	-- Add the parameters for the stored procedure here
		
	@IdDocumento int,
	@IdTipoOperacion int, 
	@IdFlujoTarea int,
	@IdProveedor int,
	@IdEstatusOperacion int, 
	@IdEstadoFlujo int,
	@IdAsignador int, 
	@Descripcion nvarchar(MAX),
	@IdVigencia int, 
	@IdPrioridad int 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DescripcionH nvarchar(MAX)
	DECLARE @IdOperacion INT

    -- Agregar Operación Si IdFlujoTarea =  0 Es una operación que no tiene flujo de tarea
	 
	IF @IdFlujoTarea <> 0 
		BEGIN 
			--SE OBTIENE EL IDOPERACION SI ES QUE EXISTE CON LOS MISMOS DATOS
			SET @IdOperacion = (SELECT TOP 1 
							IdOperacion
						FROM dbo.TA_Operacion 
						WHERE IdDocumento = @IdDocumento 
							AND IdTipoOperacion = @IdTipoOperacion
							AND IdProveedor = @IdProveedor
							);

			IF ISNULL(@IdOperacion,0) = 0
			BEGIN
			
			    INSERT INTO TA_Operacion(IdDocumento,IdTipoOperacion,IdFlujoTarea,IdEstatusOperacion,IdEstadoFlujo,IdProveedor,IdAsignador,FechaRegistro,Descripcion, IdVigencia, IdPrioridad)
				VALUES(@IdDocumento,@IdTipoOperacion,@IdFlujoTarea,@IdEstatusOperacion,@IdEstadoFlujo,@IdProveedor,@IdAsignador,GETDATE(), @Descripcion,@IdVigencia,@IdPrioridad)

				SET @IdOperacion = (SCOPE_IDENTITY());

			END
			
		END 
	ELSE 
		BEGIN 
			
			SET @IdOperacion = (SELECT TOP 1 
							IdOperacion
						FROM dbo.TA_Operacion 
						WHERE IdDocumento = @IdDocumento 
							AND IdTipoOperacion = @IdTipoOperacion
							AND IdProveedor = @IdProveedor
							);

			IF ISNULL(@IdOperacion,0) = 0
			BEGIN

				INSERT INTO TA_Operacion(IdDocumento,IdTipoOperacion,IdEstatusOperacion,IdProveedor,IdAsignador,FechaRegistro,Descripcion, IdVigencia, IdPrioridad)
				VALUES(@IdDocumento,@IdTipoOperacion,@IdEstatusOperacion,@IdProveedor,@IdAsignador,GETDATE(), @Descripcion,@IdVigencia,@IdPrioridad)

				SET @IdOperacion = (SCOPE_IDENTITY())
			END

			
		END 

	----Agregar Evento al Historial del Flujo de Tarea----

	SET @DescripcionH = 'El Usuario ' +(SELECT Nombre FROM S_USuario WHERE IdUsuario = @IdAsignador)+ ' ha registrado la Tarea de Tipo ' + (SELECT NombreOperacion FROM TA_TipoOperacion WHERE IdTipoOperacion=@IdTipoOperacion)

	INSERT INTO TA_HistorialFlujoTarea(IdOperacion, Fecha,Descripcion, IdEstadoFlujo)
	VALUES(@IdOperacion,GETDATE(),@DescripcionH,1)
	


	SELECT @IdOperacion AS IdOperacion

END

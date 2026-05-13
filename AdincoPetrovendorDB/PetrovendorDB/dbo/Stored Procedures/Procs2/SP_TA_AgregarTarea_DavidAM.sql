-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Permite agregar un flujo de tareas
-- =============================================
create PROCEDURE  [dbo].[SP_TA_AgregarTarea_DavidAM]
	-- Add the parameters for the stored procedure here
		
	@NombreTarea nvarchar(MAX),
	@IdEstatus int,
	@IdAprobador int, 
	@Visto bit,
	@NoSecuencia int,
	@IdOperacion int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdOperacionf INT,
		@IdTarea INT

	IF @IdOperacion = 0 
		BEGIN
			SET @IdOperacionf = NULL
		END 
	ELSE 
		BEGIN 
			SET @IdOperacionf = @IdOperacion
		END 
	
    -- Insert statements for procedure here
	INSERT INTO TA_Tarea(NombreTarea,FechaRegistro,IdEstatus,Activo, Visto,IdAprobador,NoSecuencia,IdOperacion)
	VALUES(@NombreTarea,GETDATE(),@IdEstatus,1, @Visto,@IdAprobador,@NoSecuencia,@IdOperacionf)
	
	SET @IdTarea = @@IDENTITY

	EXEC dbo.Mobile_NotificacionPetrovendor @IdtareaIdentity = @IdTarea

	SELECT @IdTarea	
END
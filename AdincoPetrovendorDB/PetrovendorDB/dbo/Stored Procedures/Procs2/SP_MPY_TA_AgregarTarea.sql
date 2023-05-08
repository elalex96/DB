-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Permite agregar un flujo de tareas
-- =============================================
CREATE ProcEDURE  [dbo].[SP_MPY_TA_AgregarTarea] 
	-- Add the parameters for the stored procedure here
		
	@NombreTarea nvarchar(MAX),
	@IdEstatus int,
	@IdAprobador int, 
	@Visto bit,
	@IdOperacion int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdOperacionf INT 

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
	VALUES(@NombreTarea,GETDATE(),@IdEstatus,1, @Visto,@IdAprobador,NULL,@IdOperacionf)


	SELECT @@IDENTITY
	
END

-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Permite agregar un flujo de tareas
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 01/09/2020
-- Description:	asignacion del preterminado para los pedimentos comprobantes de compra directa
-- =============================================
CREATE PROCEDURE  [dbo].[SP_TA_AgregarFlujoTarea] 
	-- Add the parameters for the stored procedure here
		
	@NombreFlujo nvarchar(MAX),
	@IdTipoFlujoTarea int,
	@IdTipoOperacion int, 
	@Descripcion nvarchar(MAX),
	@Condicion bit, 
	@IdProveedor int,
	@IdUsuario INT,
	@Predeterminado BIT = 0,
	@SoloNotificar BIT = NULL
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 -- Insert statements for procedure here

	DECLARE @IdFlujoTarea INT;

	INSERT INTO TA_FlujoTarea(Nombre,Descripcion,IdTipoFlujo,IdTipoOperacion,Condicion,FechaCreacion,CreadorPor,IdProveedor,Activo,Eliminado)--,Predeterminado)
	VALUES(@NombreFlujo,@Descripcion,@IdTipoFlujoTarea,@IdTipoOperacion,@Condicion,GETDATE(),@IdUsuario,@IdProveedor,1,0)--,@Predeterminado)
    
    SET @IdFlujoTarea = SCOPE_IDENTITY()

	IF(@IdTipoOperacion = 10)
	BEGIN
		
		UPDATE	TA_FlujoTarea
		SET	Predeterminado = 0
		WHERE IdTipoOperacion = @IdTipoOperacion
		AND IdProveedor = @IdProveedor

	    UPDATE dbo.TA_FlujoTarea
		SET Predeterminado = @Predeterminado
		WHERE IdFlujoTarea = @IdFlujoTarea
	END

	IF(@IdTipoOperacion = 16 OR @IdTipoOperacion = 18 OR @IdTipoOperacion = 19)
	BEGIN
		
		UPDATE	TA_FlujoTarea
		SET	Predeterminado = 0
		WHERE IdTipoOperacion = @IdTipoOperacion
		AND IdProveedor = @IdProveedor

	    UPDATE dbo.TA_FlujoTarea
		SET Predeterminado = 1
		WHERE IdFlujoTarea = @IdFlujoTarea

	END

	IF(@SoloNotificar = 1)
	BEGIN
	    
		UPDATE dbo.TA_FlujoTarea
		SET SoloNotificar = 1
		WHERE IdFlujoTarea = @IdFlujoTarea

	END


	SELECT @IdFlujoTarea

END

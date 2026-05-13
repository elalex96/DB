-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 16/10/2017
-- Description:	actualizar flujo de aprobación de COMPRA DIRECTA 
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ActualizarFlujoCompraDirecta] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int, 
 @IdFlujoTarea int,
 @IdUsuario int, 
 @Accion nvarchar(300),
 @Nombreflujo nvarchar(MAX),
 @Descripcion nvarchar(MAX),
 @IdTipoOperacion int 

	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ExistePredeterminado INT
	 
    -- Insert statements for procedure here



	IF @Accion='UPDATE'
	BEGIN 
		
		--DECLARE @IdTipoFlujo INT
		 

		--SET @ExistePredeterminado = (SELECT COUNT(IdFlujoTarea)
		--				     FROM TA_FlujoTarea 
		--					 WHERE [IdProveedor]= @IdProveedor
		--					 AND [IdTipoOperacion]= @IdTipoOperacion
		--					 AND [Predeterminado] = 1)

			--IF @ExistePredeterminado > 0 AND @Predeterminado = 1
			--	BEGIN 
			--		UPDATE [dbo].[TA_FlujoTarea]
			--		SET Predeterminado = 0
			--		WHERE [IdTipoOperacion] = @IdTipoOperacion
			--		AND [IdProveedor] = @IdProveedor
			--	END
				
				UPDATE [dbo].[TA_FlujoTarea]
				SET 
				[Nombre] = @Nombreflujo,
				[Descripcion] = @Descripcion,
				--[Predeterminado] =@Predeterminado,
				[IdModificadoPor]=  @IdUsuario,
				[ModificadorEl] =GETDATE()
				WHERE [IdFlujoTarea]= @IdFlujoTarea AND [IdProveedor]= @IdProveedor
								
	END 
END


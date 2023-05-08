-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2017
-- Description:	Eliminar flujo de aprobación de pedido 
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ActualizarFlujoPedidoPedido] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int, 
 @IdFlujoTarea int,
 @IdUsuario int, 
 @Accion nvarchar(300),
 --@Predeterminado BIT = 0,
 @Nombreflujo nvarchar(MAX),
 @Descripcion nvarchar(MAX),
 @ValorInicial nvarchar(MAX),
 @ValorFinal nvarchar(MAX),
 @TipoFlujo nvarchar(300)

	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ExistePredeterminado INT
	 
    -- Insert statements for procedure here

	IF @Accion  = 'DELETE'
	BEGIN

		UPDATE [dbo].[TA_FlujoTarea]
		SET [Eliminado]= 1,
		[Activo]= 0,
		--[Predeterminado] = 0,
		[IdModificadoPor]=  @IdUsuario,
		[ModificadorEl] =GETDATE()
		WHERE [IdFlujoTarea]= @IdFlujoTarea AND [IdProveedor]= @IdProveedor
	END 
	

	IF @Accion='UPDATE'
	BEGIN 
		
		DECLARE @IdTipoFlujo INT
		SET @IdTipoFlujo = (SELECT IdTipoFlujoTarea FROM TA_TipoFlujoTarea WHERE Nombre = @TipoFlujo)

		--SET @ExistePredeterminado = (SELECT COUNT(IdFlujoTarea)
		--				     FROM TA_FlujoTarea 
		--					 WHERE [IdProveedor]= @IdProveedor
		--					 AND [IdTipoOperacion]= 7
		--					 AND [Predeterminado] = 1)

			--IF @ExistePredeterminado > 0 AND @Predeterminado = 1
			--	BEGIN 
			--		UPDATE [dbo].[TA_FlujoTarea]
			--		SET Predeterminado = 0
			--		WHERE [IdTipoOperacion] = 7
			--		AND [IdProveedor] = @IdProveedor
			--	END
				
				UPDATE [dbo].[TA_FlujoTarea]
				SET 
				[Nombre] = @Nombreflujo,
				[Descripcion] = @Descripcion,
				[IdTipoFlujo] = @IdTipoFlujo,
				--[Predeterminado] =@Predeterminado,
				[IdModificadoPor]=  @IdUsuario,
				[ModificadorEl] =GETDATE()
				WHERE [IdFlujoTarea]= @IdFlujoTarea AND [IdProveedor]= @IdProveedor

				UPDATE [dbo].[TA_FlujoTareaCondicion]
				SET 
				[NombreCondicion] = 'Total Pedido '+ @ValorInicial + ' a ' + @ValorFinal,
				[ValorInicial] = CAST(@ValorInicial AS float),
				[ValorFinal] = CAST (@ValorFinal AS float)
				WHERE [IdFlujoTarea]= @IdFlujoTarea

	END 
END

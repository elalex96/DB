-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 16/10/2017
-- Description:	Actualizar cabecera de flujo de aprobación de cualquier tipo de operación  
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ActualizarFlujoCabeceraGeneral] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int, 
 @IdFlujoTarea int,
 @IdUsuario int,
 @Predeterminado BIT = 0,
 @Nombreflujo nvarchar(MAX),
 @Descripcion nvarchar(MAX),
 @IdTipoOperacion INT,
 @IdContrato INT  = 0 

	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ExistePredeterminado INT
	 
    -- Insert statements for procedure here

		

		SET @ExistePredeterminado = (SELECT COUNT(IdFlujoTarea)
						     FROM TA_FlujoTarea 
							 WHERE [IdProveedor]= @IdProveedor
							 AND [IdTipoOperacion]= @IdTipoOperacion
							 AND [Predeterminado] = 1)

			IF @ExistePredeterminado > 0 AND @Predeterminado = 1
				BEGIN 
					UPDATE [dbo].[TA_FlujoTarea]
					SET Predeterminado = 0
					WHERE [IdTipoOperacion] = @IdTipoOperacion
					AND [IdProveedor] = @IdProveedor
				END
				
				UPDATE [dbo].[TA_FlujoTarea]
				SET 
				[Nombre] = @Nombreflujo,
				[Descripcion] = @Descripcion,
				[Predeterminado] =@Predeterminado,
				[IdModificadoPor]=  @IdUsuario,
				[ModificadorEl] =GETDATE()
				WHERE [IdFlujoTarea]= @IdFlujoTarea AND [IdProveedor]= @IdProveedor
								

END

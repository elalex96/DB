-- =============================================
-- Author:		DANIEL AC 
-- Create date:11/08/2017
-- Description:	Cambiar de estado el flujo de aprobación actual
-- =============================================
CREATE  PROCEDURE [dbo].[SP_TA_ActualizarFlujoPredeterminado]

@IdProveedor int,
@IdFlujoAprobacion int,
@isPredeterminado bit, 
@IdTipoFlujo int 


AS
BEGIN

DECLARE @ExistePredeterminado INT 

SET @ExistePredeterminado = (SELECT COUNT(IdFlujoTarea)
						     FROM TA_FlujoTarea 
							 WHERE [IdProveedor]= @IdProveedor
							 AND [IdTipoOperacion]= @IdTipoFlujo
							 AND [Predeterminado] = 1)

			IF @ExistePredeterminado > 0 
				BEGIN 
					UPDATE [dbo].[TA_FlujoTarea]
					SET Predeterminado = 0
					WHERE [IdTipoOperacion] = @IdTipoFlujo
					AND [IdProveedor] = @IdProveedor
				END
						
	
			UPDATE  [dbo].[TA_FlujoTarea]
			SET  [Predeterminado] = @isPredeterminado
			WHERE [IdFlujoTarea] = @IdFlujoAprobacion 
		 

			SELECT 'SUCESS'
END



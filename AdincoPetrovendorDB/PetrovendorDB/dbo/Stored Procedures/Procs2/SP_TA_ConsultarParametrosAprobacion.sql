-- =============================================
-- Author:Daniel AC
-- Create date: 28/06/2018
-- Description:	Se consulta parametros de un tipo de aprobación indicado
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarParametrosAprobacion] 

	@IdProveedor INT,
    @IdContrato    INT = 0,
    @IdUsuario     INT,
	@IdTipoOperacion INT, 
	@IdOperacion INT
	 
AS
BEGIN

	SET NOCOUNT ON;
	 
	IF @IdTipoOperacion= 2 --> APROBACIÓN DE SOLICITUD DE PEDIDO 
	BEGIN 
	
		SELECT IdDocumento FROM dbo.TA_Operacion WHERE IdOperacion= @IdOperacion 

	END

	IF @IdTipoOperacion= 9 --> APROBACIÓN DE PEDIDO 
	BEGIN 
	
		SELECT IdDocumento, NoVersion FROM dbo.TA_Operacion WHERE IdOperacion= @IdOperacion 

	END

	IF @IdTipoOperacion= 14 --> APROBACIÓN DE COMPRA DIRECTA 
	BEGIN 		  
		SELECT IdDocumento, IdAsignador FROM dbo.TA_Operacion WHERE IdOperacion= @IdOperacion 

	END


END


-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_EliminarDistribuidorAutorizadoDe] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int ,
@IdUsuario int, 
@IdDistribuidorAutorizado int 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

	 
	UPDATE [PV_DistribuidorAutorizado]
	SET [Activo]=0,
	[IdEditadoPor]=@IdUsuario,
	[EditadoEl]=GETDATE()
	WHERE [IdDistribuidorAutorizado]=@IdDistribuidorAutorizado


END
 
	


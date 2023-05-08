

-- =============================================
-- Author: DANIEL AC
-- Create date: 02/10/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ActualizarPerfilGiroEmpresarial] 
	-- Add the parameters for the stored procedure here

@IdPerfilGiroEmpresarial	int ,
@IdUsuario int, 
@IdProveedor int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	 
	  
	 
	  UPDATE [dbo].[PV_PerfilGiroEmpresarial]
	  SET [Activo]=0,
		[IdEditadoPor] = @IdUsuario,
		[EditadoEl]=GETDATE()
	  WHERE [IdPerfilGiroEmpresarial]=@IdPerfilGiroEmpresarial AND [IdProveedor] = @IdProveedor 
 


END
 


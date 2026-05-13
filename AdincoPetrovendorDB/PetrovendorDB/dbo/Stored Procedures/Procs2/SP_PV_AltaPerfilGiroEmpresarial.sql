

-- =============================================
-- Author: DANIEL AC
-- Create date: 02/10/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_AltaPerfilGiroEmpresarial] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int ,
@IdUsuario int, 
@IdGiroEmpresarial int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	 
	DECLARE @contador int 

	SET @contador = (select count(IdGiroEmpresarial) from [PV_PerfilGiroEmpresarial] where [IdGiroEmpresarial] = @IdGiroEmpresarial and [IdProveedor]= @IdProveedor and [Activo] =1)

	IF  @contador = 0 
	BEGIN 
		INSERT INTO [dbo].[PV_PerfilGiroEmpresarial]([IdGiroEmpresarial],[IdProveedor],[IdCreadorPor],[CreadoEl],[Activo])
		VALUES(@IdGiroEmpresarial, @IdProveedor,@IdUsuario,GETDATE(),1)
	END 
	  

	 SELECT 'SUCCESS INSERT'


END
 


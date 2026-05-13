-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar ficha técnica
-- Author: Daniel AC
-- Update date: 08/09/17
-- Description: Se actualizo para crear filtro de ofertas finalizadas y en cotización
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_FichaTecnicaPeticionOfertaDetalle] 
	-- Add the parameters for the stored procedure here
	
	@IdPeticionOfertaDetalle int
	
 	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here	


			SELECT M.[IdMaterial],M.[DescripcionCorta]+'.pdf', ISNULL(M.[FichaTecnica],'')
			FROM [dbo].[MM_Material] AS M
			INNER JOIN  [dbo].[MM_PeticionOfertaDetalle] AS POD ON  POD.[IdMaterialVendedor]  = M.[IdMaterial]
			WHERE [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle 
			
		


END


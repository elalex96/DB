-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaMaterialesSolPed]
	-- Add the parameters for the stored procedure here
 @IdTipoPedido int  

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

  --       SELECT Sub.IdSubFamilia AS IdMaterial,
  --              Sub.SubFamilia AS DescripcionCorta,
		--		Sub.SubFamilia AS DescripcionLarga,
  --              U.Unidad AS NombreUnidad,
		--		U.IdUnidad			 
			
  --       FROM PV_MM_MaterialSubFamilia AS Sub
  --            INNER JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo Alls ON Sub.IdSubFamilia = Alls.IdSubFamilia
  --            INNER JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = Alls.IdUnidad
		--ORDER BY DescripcionCorta ASC

		DECLARE @IdTipoCatalogoMaestro int 
		---DECLARE @IdTipoPedido int  =10001
		IF @IdTipoPedido = 10000  --- MATERIALES
			SET @IdTipoCatalogoMaestro = 1
		
		IF  @IdTipoPedido = 10001  --- SEERVICIOS
			SET @IdTipoCatalogoMaestro = 2

			SELECT MM.IdMaestro AS IdMaterial,
                MM.TextoCorto  AS DescripcionCorta,
				MM.TextoLargo AS DescripcionLarga,
                U.Unidad AS NombreUnidad,
				U.IdUnidad			 
	         FROM  MM_Maestro AS MM
			  INNER JOIN PV_MM_MaterialSubFamilia AS Sub ON SUB.IdSubFamilia = MM.IdSubFamilia
              INNER JOIN PV_MM_GrupoFamiliaSubFamiliaUnidadTipo Alls ON Sub.IdSubFamilia = Alls.IdSubFamilia
              INNER JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = Alls.IdUnidad AND MM.IdTipoCatalogoMaestro=@IdTipoCatalogoMaestro
			ORDER BY DescripcionCorta ASC

     END
	 

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarInfoCatalogoTemporal]
@IdCatalogo INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	   SELECT
	   [IdAltaCatalogoProveedor]
      ,[DescripcionCorta]
      ,[DescripcionLarga]
      ,[UMB]
      ,[IdTipoMoneda]
      ,[Precio]
      ,[IdTipoCatalogo]
      ,[CreadoPor]
      ,[IdProveedor],
	  IdSubFamilia
	  FROM PV_MM_AltaCatalogoProveedorTemp 
	  WHERE IdAltaCatalogoProveedor = @IdCatalogo AND IsActivo = 1 


END


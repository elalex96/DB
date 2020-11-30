-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consultar todos los materiales Compras>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarMaterialesCompras] 
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  SELECT MMM.IdMaterial, MMM.DescripcionCorta, MMM.Modelo, MMM.Marca, SP.RazonSocial AS Empresa, US.Nombre AS CreadoPor, MMM.FechaAlta
  FROM MM_MaterialesCompraProveedor AS MCP
  LEFT JOIN MM_Material AS MMM ON MMM.IdMaterial = MCP.IdMaterial
  LEFT JOIN S_Proveedor AS SP ON SP.IdProveedor = MMM.IdProveedor
  LEFT JOIN S_Usuario AS US ON US.IdUsuario = MMM.CreadoPor

END


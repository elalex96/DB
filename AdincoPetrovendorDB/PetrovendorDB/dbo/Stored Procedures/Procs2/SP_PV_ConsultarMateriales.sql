-- =============================================
-- Author:		<Alexander G>
-- Create date: <13/09/2017>
-- Description:	<Consultar todos los materiales>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarMateriales] 
	-- Add the parameters for the stored procedure here
AS	
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
  SELECT MMM.IdMaterial, MMM.DescripcionCorta, MMM.Costo, MMM.Modelo, MMM.Marca, MMM.CreadoPor, SP.RazonSocial AS Empresa, US.Nombre AS CreadoPor, MMM.FechaAlta
  FROM MM_Material AS MMM
  LEFT JOIN S_Proveedor AS SP ON SP.IdProveedor = MMM.IdProveedor
  LEFT JOIN S_Usuario AS US ON US.IdUsuario = MMM.CreadoPor

END


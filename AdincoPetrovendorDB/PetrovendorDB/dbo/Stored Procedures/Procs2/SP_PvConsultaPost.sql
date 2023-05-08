-- =============================================
-- Author:		Daniel AC
-- Create date: 03/03/2018
-- Description:	Actulice retorno de imagen nvarchar a imagenProveedor de tipo image
-- =============================================
CREATE PROCEDURE [dbo].[SP_PvConsultaPost] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select top 15 PVP.IdPublicacion, PVP.Descripcion,PVP.FechaPublicacion, PVP.Imagen AS ImagenPub,SP.IdProveedor, SP.RazonSocial, IP.ImagenProveedor AS ImagenPerfil
	from PV_Publicacion PVP
	join S_Proveedor SP on PVP.IdProveedor = SP.IdProveedor
	left join S_ImagenPerfil IP on IP.IdProveedor=SP.IdProveedor
	where IsPublicado = 0
	order by PVP.FechaPublicacion desc

END

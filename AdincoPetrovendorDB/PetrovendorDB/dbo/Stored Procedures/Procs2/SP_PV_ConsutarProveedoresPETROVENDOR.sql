
CREATE PROCEDURE [dbo].[SP_PV_ConsutarProveedoresPETROVENDOR]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 select p.IdProveedor, RFC, RazonSocial, p.IdNacionalidad, n.Nacionalidad, Pais, Entidad, Municipio, GE.GiroProveedor AS Giro
    from Petrovendor.dbo.S_Proveedor p
	inner join S_Nacionalidad n 
	on p.IdNacionalidad = n.IdNacionalidad
	LEFT JOIN dbo.PV_PerfilGiroEmpresarial AS PGE ON PGE.IdProveedor = p.IdProveedor
	LEFT JOIN dbo.PV_GiroEmpresarial AS GE ON GE.IdGiroProveedor = PGE.IdGiroEmpresarial
	where p.Activo = 1 and IsEliminado = 0

END



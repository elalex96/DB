
CREATE PROCEDURE [dbo].[SP_PV_ConsutarProveedoresGiroPETROVENDOR]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT GE.GiroProveedor AS Giro
FROM dbo.PV_PerfilGiroEmpresarial AS PGE
LEFT JOIN dbo.PV_GiroEmpresarial AS GE ON GE.IdGiroProveedor = PGE.IdGiroEmpresarial
	

END




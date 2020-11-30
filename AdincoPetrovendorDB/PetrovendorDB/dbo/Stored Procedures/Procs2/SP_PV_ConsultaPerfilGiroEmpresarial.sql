-- =============================================
-- Author: DANIEL AC
-- Create date: 02/10/2017
-- Description:	
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <16/02/2018>
-- Description:	<Se agrega eliminado logico y parametros de contrato>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaPerfilGiroEmpresarial] 
	@IdProveedor	int  ,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
	
AS
BEGIN
	SELECT [IdPerfilGiroEmpresarial] AS IdPerfilGiroEmpresarial,[GiroProveedor] AS GiroEmpresarial, GH.GiroProovedor AS Actividad,GP.GiroProovedor AS TipoActividad
	FROM [dbo].[PV_PerfilGiroEmpresarial] AS PGE
		INNER JOIN [dbo].[PV_GiroEmpresarial] AS GE ON GE.[IdGiroProveedor]= PGE.[IdGiroEmpresarial]
		INNER JOIN  PV_GiroComercialHijo AS GH ON GH.IdGiroProveedorHijo = GE.PV_GiroComercialHijo
		INNER JOIN PV_GiroComercialPadre AS GP ON GP.IdGiroProveedorPadre = GH.IdGiroProveedorPadre
	WHERE PGE.[IdProveedor]=@IdProveedor 
		AND PGE.Activo = 1
END


-- =============================================
-- Author:		Daniel AC
-- Create date: 03-10-17
-- Description:	
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <15-02-2018>
-- Description:	<Se agrega filtro para no mostrar giros ya agregados por proveedor y se agregan parametros de contrato>
-- =============================================
CREATE procedure [dbo].[SP_PV_GiroEmpresarial]
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

as
begin

	select idGiroProveedor,GiroProveedor, GH.GiroProovedor AS Actividad,GP.GiroProovedor AS TipoActividad
	from  PV_GiroEmpresarial AS GE 
	INNER JOIN  PV_GiroComercialHijo AS GH ON GH.IdGiroProveedorHijo = GE.PV_GiroComercialHijo
	INNER JOIN PV_GiroComercialPadre AS GP ON GP.IdGiroProveedorPadre = GH.IdGiroProveedorPadre
	WHERE GE.IdGiroProveedor NOT IN (SELECT IdGiroEmpresarial FROM dbo.PV_PerfilGiroEmpresarial WHERE IdProveedor = @IdProveedor AND Activo = 1)
end

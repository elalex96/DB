-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <12/02/2018>
-- Description:	<Obtiene la lista de los materiales que estan relacionados con algun material de catalogo maestro>
-- =============================================
CREATE PROCEDURE SP_MM_MaterialesClasificados
@IdMaterial INT,

@IdContrato INT,
@IdUsuario INT,
@FechaRegistro DATETIME

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT M.IdMaterial,M.DescripcionCorta,M.DescripcionLarga,M.IdUnidad,U.Unidad,M.IdProveedor,P.RazonSocial,M.IdMaestro
	FROM dbo.MM_Material M
	INNER JOIN dbo.MM_Maestro MA
	ON MA.IdMaestro = M.IdMaestro
	INNER JOIN dbo.PV_MM_MaterialUnidad U
	ON U.IdUnidad = M.IdUnidad
	INNER JOIN dbo.S_Proveedor p 
	ON p.IdProveedor = M.IdProveedor
	WHERE MA.IdMaestro = @IdMaterial

END

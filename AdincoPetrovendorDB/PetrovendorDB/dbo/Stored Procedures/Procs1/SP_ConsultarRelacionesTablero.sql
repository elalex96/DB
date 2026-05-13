-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <09/07/2020>
-- Description:	<Consulta la lista de relaciones de tableros>
-- =============================================
CREATE PROCEDURE SP_ConsultarRelacionesTablero
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	RT.IdTableroTipoUsuarioRol,
	P.RazonSocial AS Proveedor,
	TU.NombreTipoUsuario,
	ISNULL(R.Rol, '---') Rol,
	ISNULL(ETC.NombreMostrar,'---') NombreTablero,
	CO.NumeroContrato + ' - ' + AC.NombreAreaContractual AS NumeroContrato
	FROM 
	dbo.Relacion_TableroRolTipo RT
	LEFT JOIN dbo.S_Proveedor P
		ON P.IdProveedor = RT.IdProveedor
	LEFT JOIN dbo.S_Rol R
		ON R.IdRol = RT.IdRol
	LEFT JOIN dbo.S_TipoUsuario TU
		ON TU.IdTipoUsuario = RT.IdTipoUsuario
	LEFT JOIN Adinco.dbo.EN_TableroContrato ETC
		ON ETC.IdTableroContrato = RT.IdTablero
	LEFT JOIN Adinco.dbo.CO_Contrato CO
		ON CO.IdContrato = RT.IdContrato
	INNER JOIN adinco.dbo.CO_AreaContractual AC
		ON CO.IdAreaContractual = AC.IdAreaContractual
	WHERE RT.Activo = 1

END

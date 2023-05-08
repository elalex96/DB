-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <29/06/2020>
-- Description:	<Consulta los contratos,tipos de usuario, roles y tableros de petrovendor>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarParametrosRelacionTablero] -- 420
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- contratos
	SELECT 
	CO.IdContrato id,CO.NumeroContrato + ' - ' + AC.NombreAreaContractual AS [text]
	FROM
	dbo.S_UsuarioProveedor UP
	INNER JOIN adinco.dbo.CO_Contrato CO
		ON CO.IdContrato = UP.IdContrato
	INNER JOIN dbo.S_Proveedor P
		ON P.IdProveedor = UP.IdProveedor
	INNER JOIN dbo.S_Usuario U
		ON U.IdUsuario = UP.IdUsuario
	INNER JOIN adinco.dbo.CO_AreaContractual AC
		ON CO.IdAreaContractual = AC.IdAreaContractual
	WHERE UP.IdProveedor = @IdProveedor
	AND ISNULL(P.IsEliminado,0) = 0
	AND U.Activo = 1
	GROUP BY CO.IdContrato,UP.IdProveedor,CO.NumeroContrato,AC.NombreAreaContractual

	-- tipos de usuario
	SELECT IdTipoUsuario id,NombreTipoUsuario [text] FROM dbo.S_TipoUsuario WHERE Activo = 1

	-- roles de usuario
	SELECT IdRol id,Rol [text] FROM dbo.S_Rol

	-- tableros
	SELECT IdTableroContrato id, ISNULL(NombreMostrar,'---') + '( ' + Workbook + ' )' AS [text] FROM adinco.dbo.EN_TableroContrato 



END

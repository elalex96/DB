-- =============================================
-- Author: Daniel AC
-- Create date: 14/11/2019
-- Description: obtener los usuarios de compras separados  comas
-- =============================================

CREATE FUNCTION Fn_ObtenerUsuariosComprasCC
	( @IdCentroCosto INT,
	  @IdProveedor INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @Retorno NVARCHAR(MAX)

		SELECT	@Retorno =
			( SELECT	STUFF (
							(	SELECT		CAST(' ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), CCG.IdUsuario )
								FROM		dbo.CC_CentroCostoGrupoCompras AS CCG
								INNER JOIN	dbo.CC_CentroCosto AS CC
									ON CC.IdCentroCosto = CCG.IdCentroCosto
								INNER JOIN	dbo.S_Usuario AS U
									ON U.IdUsuario = CCG.IdUsuario
								INNER JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario															
								WHERE
											UP.IdProveedor = @IdProveedor
											AND CCG.IdCentroCosto = @IdCentroCosto
											AND U.Activo = 1
											AND CCG.Activo=1
								GROUP BY CCG.IdUsuario,U.Nombre
								ORDER BY	U.Nombre
								FOR XML PATH ( '' )), 1, 1, '' ) AS IdUsuario )

		RETURN @Retorno
	END



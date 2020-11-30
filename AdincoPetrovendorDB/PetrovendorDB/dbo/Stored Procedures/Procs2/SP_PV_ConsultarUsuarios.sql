-- =============================================
-- Author: DANIEL AC
-- Create date: 31/08/2017
-- Description:	CONSULTAR USUARIO
-- Author: DANIEL AC
-- Update date: 07/03/2018
-- Description:	Se agrego groupby 
-- =============================================
-- Author:		Jose Roman
-- Update date: 25/04/2018
-- Description:	Se agrega filtro por contrato  
-- =============================================
-- =============================================
-- Author:		Pedro Acu�a
-- Update date: 13/08/2018
-- Description:	Se agrega el retorno de los roles separados por coma  
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarUsuarios] @IdProveedor INT ,
													/*--------------------parametros contrato  --------------------*/
												 @IdContrato INT = NULL, @IdUsuario INT = NULL ,
												 @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
	BEGIN
		SELECT		U.[IdUsuario], U.[Nombre], dbo.Fn_ObtenerRolUsuario ( P.IdProveedor, U.IdUsuario ) AS IdRol
		FROM		S_Usuario AS U
		INNER JOIN	S_USUARIOPROVEEDOR AS UP
			ON UP.IDUSUARIO = U.IdUsuario
		INNER JOIN	S_Proveedor AS P
			ON P.IDPROVEEDOR = UP.IDPROVEEDOR
		WHERE
					UP.IdProveedor = @IdProveedor
					AND U.Activo = 1
					AND
						(	u.IsEliminado = 0
							OR		u.IsEliminado IS NULL )
					AND UP.IdContrato = @IdContrato
		GROUP BY	U.[IdUsuario], U.[Nombre], P.IdProveedor
	END

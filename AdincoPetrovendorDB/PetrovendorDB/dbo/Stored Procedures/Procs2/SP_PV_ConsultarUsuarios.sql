USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_PV_ConsultarUsuarios]    Script Date: 26/11/2021 01:33:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 25/11/21
-- Description:	se optimiza el sp para disminuir la carga de los modulos donde es usado
-- =============================================
ALTER PROCEDURE [dbo].[SP_PV_ConsultarUsuarios] 
	@IdProveedor INT ,
/*--------------------parametros contrato  --------------------*/
	@IdContrato INT = NULL, @IdUsuario INT = NULL ,
	@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
		SELECT
			U.IdUsuario,
			U.Nombre,
			STUFF((SELECT CAST(' ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), UR.IdRol )
							FROM dbo.S_UsuarioRol AS UR
							WHERE UR.IdUsuario = U.IdUsuario
									AND UR.Activo = 1
							ORDER BY UR.IdRol
							FOR XML PATH ('')),1,1, '') AS IdRol
		FROM dbo.S_UsuarioProveedor AS UP WITH (NOLOCK)
			JOIN dbo.S_Usuario AS U WITH (NOLOCK) ON UP.IdUsuario = U.IdUsuario 
				AND UP.IdProveedor = @IdProveedor
				AND U.Activo = 1
				AND (u.IsEliminado = 0 OR u.IsEliminado IS NULL)
				AND UP.IdContrato = @IdContrato
			JOIN dbo.S_Proveedor AS P WITH (NOLOCK) ON UP.IdProveedor = P.IdProveedor 
				AND UP.IdProveedor = @IdUsuario
		GROUP BY U.IdUsuario, U.Nombre, P.IdProveedor, UP.IdUsuario


END

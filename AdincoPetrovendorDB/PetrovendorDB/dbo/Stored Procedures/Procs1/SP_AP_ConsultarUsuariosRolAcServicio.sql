USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_AP_ConsultarUsuariosRolAcServicio]    Script Date: 28/02/2022 08:46:36 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <Consulta la lista de usuarios con rol de "Aceptación de servicio">
-- Description:	<Description,,>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/02/2022>
-- Description:	<validacion para usuarios dea>
-- =============================================
ALTER PROCEDURE [dbo].[SP_AP_ConsultarUsuariosRolAcServicio] --420,3
@IdProveedor INT,
@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RFC VARCHAR(100) = (SELECT TOP 1 RFC FROM S_Proveedor WHERE IdProveedor = @IdProveedor AND Activo = 1);

	--VALIDACION PARA DEA
	IF EXISTS (SELECT * FROM DEA_Proveedor WHERE RFC = @RFC)
	BEGIN
		
		SELECT U.IdUsuario AS Asignado,U.Nombre FROM dbo.S_UsuarioRol UR
		LEFT JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = UR.IdUsuario
		LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = UP.IdUsuario
		WHERE UP.IdProveedor = @IdProveedor 
		AND ISNULL(U.IsEliminado,0) = 0
		AND UP.IdContrato = @IdContrato

	END
	ELSE
	BEGIN 
		
		SELECT U.IdUsuario AS Asignado,U.Nombre FROM dbo.S_UsuarioRol UR
		LEFT JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = UR.IdUsuario
		LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = UP.IdUsuario
		WHERE UP.IdProveedor = @IdProveedor 
		AND ISNULL(U.IsEliminado,0) = 0
		AND UP.IdContrato = @IdContrato
		AND UR.IdRol = 8 -- aceptación servicio

	END

END

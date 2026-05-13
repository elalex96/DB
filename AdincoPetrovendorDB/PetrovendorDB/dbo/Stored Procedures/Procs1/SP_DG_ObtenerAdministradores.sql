USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_DG_ObtenerAdministradores'
)
    DROP PROCEDURE SP_DG_ObtenerAdministradores;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Create date: <02/Enero/2018>
-- Description:	<Se Obtienen los admnisitradores por proveedor >
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date:09/04/2025
-- Description:	Se agrega group by para evitar duplicados
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_ObtenerAdministradores]
    @IdProveedor INT,
    @IdUsuario INT,
    @IdContrato INT,
    @fchRegistro DATETIME
AS
BEGIN
    SELECT usuario.IdUsuario,
           usuario.Nombre,
           usuario.Correo
    FROM dbo.S_Usuario usuario (NOLOCK)
        INNER JOIN dbo.S_UsuarioProveedor uProv (NOLOCK)
            ON  usuario.IdUsuario = uProv.IdUsuario
    WHERE usuario.IdTipoUsuario = 3  --> CTE TIPO DE USUARIO
          AND usuario.Activo = 1
          AND usuario.IsEliminado = 0
          AND uProv.IdProveedor = @IdProveedor
    GROUP BY 
	 usuario.IdUsuario,
     usuario.Nombre,
     usuario.Correo  
END
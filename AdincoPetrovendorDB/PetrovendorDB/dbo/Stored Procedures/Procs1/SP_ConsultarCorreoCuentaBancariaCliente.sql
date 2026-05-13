-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarCorreoCuentaBancariaCliente] @IdCliente INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @TieneUsuario INT;
             SET @TieneUsuario =
(
    SELECT COUNT(u.IdUsuario)
    FROM S_Usuario u
         INNER JOIN S_UsuarioProveedor up ON u.IdUsuario = up.IdUsuario
    WHERE up.IdProveedor = @IdCliente
);
             IF(@TieneUsuario > 0)
                 BEGIN
                     SELECT u.Correo,
                            u.Nombre,
                            p.RazonSocial
                     FROM S_Usuario u
                          INNER JOIN S_UsuarioProveedor up ON u.IdUsuario = up.IdUsuario
                          INNER JOIN S_Proveedor p ON up.IdProveedor = p.IdProveedor
                     WHERE up.IdProveedor = @IdCliente
                           AND u.IsEliminado = 0
                           AND u.IdTipoUsuario = 3;
                 END;
                 ELSE
                 BEGIN
                     SELECT p.CorreoProveedor,
                            p.RazonSocial
                     FROM S_Proveedor p
                     WHERE p.IdProveedor = @IdCliente
                           AND p.IsEliminado = 0;
                 END;
         END;

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarCorreoSiExiste]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EXISTE INT = (SELECT COUNT(CorreoProveedor) FROM  S_Proveedor WHERE IdProveedor = @IdProveedor)

	IF (@EXISTE > 0)
	BEGIN
	SELECT CorreoProveedor FROM  S_Proveedor WHERE IdProveedor = @IdProveedor
	END
	ELSE
	BEGIN
	DECLARE @EXISTE_EN_USUARIOS INT = (
	                                   SELECT COUNT(U.Correo) FROM dbo.S_Usuario U
									   INNER JOIN dbo.S_UsuarioProveedor UP
									   ON UP.IdUsuario = U.IdUsuario
									   INNER JOIN dbo.S_Proveedor P
									   ON P.IdProveedor = UP.IdProveedor
									   WHERE P.IdProveedor = @IdProveedor)

    IF (@EXISTE_EN_USUARIOS > 0)
	BEGIN
	SELECT U.Correo FROM dbo.S_Usuario U
					       INNER JOIN dbo.S_UsuarioProveedor UP
						   ON UP.IdUsuario = U.IdUsuario
						   INNER JOIN dbo.S_Proveedor P
						   ON P.IdProveedor = UP.IdProveedor
						   WHERE P.IdProveedor = @IdProveedor
	END
	ELSE
	BEGIN
	SELECT 'SIN_CORREO'
	END
	END
	

END



/****** Object:  StoredProcedure [dbo].[SP_ConsultarFacturaCliente]    Script Date: 11/9/2017 9:32:05 AM ******/
SET ANSI_NULLS ON

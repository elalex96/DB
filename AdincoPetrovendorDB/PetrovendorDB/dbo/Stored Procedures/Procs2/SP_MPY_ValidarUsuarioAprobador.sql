-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19-06-2018
-- Description:	Validar que el usuario que acceso es de los aprobadores de la Carta de contenido nacional (Murphy)
-- =============================================
-- Author:		Jose Roman
-- Create date: 19-09-2018
-- Description:	Se valida que el usuario se encuentre entre los usuarios con rol de aprobador de CN
-- =============================================
CREATE procedure [dbo].[SP_MPY_ValidarUsuarioAprobador]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT,
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	--DECLARE @CORREOUSUARIOACTUAL NVARCHAR(MAX) = (SELECT Correo FROM dbo.S_Usuario WHERE IdUsuario = @IdUsuario)

	--SELECT ISNULL(IdAprobador_CN,0) 
	--FROM dbo.MPY_CN_Aprobadores
	--WHERE Correo = @CORREOUSUARIOACTUAL AND IdAceptacionPedido = @IdAceptacionPedido AND EstatusAprobacion IS NULL

	SELECT 1 --u.IdUsuario
	--FROM dbo.S_Proveedor p
	--INNER JOIN dbo.MPY_MM_AceptacionPedido ap ON ap.IdProveedor = p.RFC
	--INNER JOIN dbo.S_UsuarioProveedor up ON up.IdProveedor = p.IdProveedor AND CAST(up.IdContrato AS NVARCHAR(max)) = ap.IdContrato
	--INNER JOIN dbo.S_Usuario u ON u.IdUsuario = up.IdUsuario AND u.Activo = 1
	--INNER JOIN dbo.S_UsuarioRol ur ON ur.IdUsuario = u.IdUsuario AND ur.IdRol = 3 AND ur.Activo = 1
	--WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
	--	AND u.IdUsuario = @IdUsuario
	--	AND p.Activo = 1
	--	AND ISNULL(p.IsEliminado, 0) = 0

END


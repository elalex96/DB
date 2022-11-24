-- =============================================
-- Author:		<josue, glez>
-- Create date: <12-05-2018>
-- Description:	<Consulta la empresa por iDtoken>
-- =============================================
CREATE PROCEDURE WA_SP_ConsultaEmpresaXToken 
	-- Add the parameters for the stored procedure here
	
	@Token VARCHAR(50),
	@IdContrato INT, 
	@IdUsuarioSistema  INT =  2205
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT P.IdProveedor, T.IdUsuario FROM	dbo.S_Proveedor P 
	LEFT JOIN dbo.WA_Token T ON p.IdProveedor = T.IdProveedor
	LEFT JOIN dbo.S_UsuarioProveedor UP ON P.IdProveedor = UP.IdProveedor
	WHERE	T.Token = @Token
	AND UP.IdContrato = @IdContrato AND P.Activo = 1
	AND UP.IdUsuario = @IdUsuarioSistema

END

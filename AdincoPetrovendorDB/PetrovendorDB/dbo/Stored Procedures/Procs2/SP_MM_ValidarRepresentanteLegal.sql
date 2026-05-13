-- =============================================
-- Author:		DANIEL AC 
-- Create date: 08/05/2018
-- Description:	CAMBIO DE REFERENCIA DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <08/03/2019>
-- Description:	<se modifica la manera en que se relaciona los documentos de tipo regimen 3>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ValidarRepresentanteLegal] 
	-- Add the parameters for the stored procedure here
	@IdTipoRegimen INT,
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @Representante NVARCHAR(MAX)
    -- Insert statements for procedure here
	IF @IdTipoRegimen = 2
	BEGIN
		SELECT P.RazonSocial, DOC.IdDocumento 
		FROM S_Proveedor AS P
		JOIN dbo.S_Documento_S3 AS DOC ON DOC.IdProveedor = P.IdProveedor AND DOC.Activo = 1
		WHERE P.IdProveedor = @IdProveedor AND DOC.IdTipoDocumento = 2
	END

	IF @IdTipoRegimen = 1
	BEGIN
		SELECT RL.Nombre, DOC.IdDocumento
		FROM dbo.DG_RepresentanteLegal AS RL
		INNER JOIN dbo.S_Documento_S3 AS DOC ON DOC.IdProveedor = RL.IdProveedor 
			AND DOC.Activo = 1 
			AND RL.IsActivo = 1 
			AND RL.IdDocumento = DOC.IdDocumento
		WHERE RL.IdProveedor = @IdProveedor 
	END

	IF @IdTipoRegimen = 3
	BEGIN
		SELECT TOP 1 U.Nombre AS RepresentanteLegal
		FROM S_Proveedor AS P
		JOIN S_UsuarioProveedor UP ON P.IdProveedor = UP.IdProveedor
		JOIN S_Usuario U ON UP.IdUsuario = U.IdUsuario
		WHERE U.IdTipoUsuario = 3 AND P.IdProveedor = @IdProveedor
	END
END

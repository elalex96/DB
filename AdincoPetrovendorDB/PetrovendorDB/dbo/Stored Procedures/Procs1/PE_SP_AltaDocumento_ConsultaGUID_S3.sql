CREATE procedure [dbo].[PE_SP_AltaDocumento_ConsultaGUID_S3]

	@IdProveedor INT,
	@IdDistribuidorAutorizadoDe INT    

AS
BEGIN

	DECLARE @IDENTIFICADOR_S3 NVARCHAR(MAX)

	SELECT @IDENTIFICADOR_S3 = D.Identificador
	FROM dbo.S_Documento_S3 D
	INNER JOIN dbo.PV_DistribuidorAutorizado DA ON D.IdDocumento=D.IdDocumento
	WHERE IdDistribuidorAutorizado = @IdDistribuidorAutorizadoDe AND D.IdProveedor=@IdProveedor AND D.IdTipoDocumento=21 --> DISTRIBUIDOR AUTORIZADO DE ...

	SELECT ISNULL(@IDENTIFICADOR_S3,'')

END
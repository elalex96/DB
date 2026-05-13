
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	CONSULTAR DETALLE DEL DOCUMENTO 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaDocumentoDistribuidorAutorizado_S3]
    -- Add the parameters for the stored procedure here

    @IdDistribuidorAutorizado INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from

    SELECT		'Distribuidor Autorizado ' + NombreEmpresa + '.pdf' AS NombreDocumento,
				D.IdDocumento,
				D.Identificador,
				D.Extension,
				D.Carpeta,
				D.Mime,
				D.Bucket
    FROM		[dbo].[PV_DistribuidorAutorizado]	DA
	INNER JOIN	S_Documento_S3						D
	ON			D.IdDocumento						=	DA.IdDocumento
    WHERE		D.IdTipoDocumento					=	21
	AND			DA.IdDistribuidorAutorizado			=	@IdDistribuidorAutorizado;

/* D.IdTipoDocumento=21 --> DOCUMENTO DE Distribuidor Autorizado : TODOS LOS ARCHIVOS DE ESTE TIPO SON PDF */
END;
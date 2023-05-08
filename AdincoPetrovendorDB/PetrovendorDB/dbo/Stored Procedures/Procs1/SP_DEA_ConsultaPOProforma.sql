-- =============================================
-- Author:		Alexander Gomez
-- Create date: 13/12/2022
-- Description:	consulta de la PO y la Proforma de un pedido y aceptacion
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultaPOProforma]
	-- Add the parameters for the stored procedure here
	@IdPedido INT,
	@IdAceptacion INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdDocumentoProforma INT;

    -- Insert statements for procedure here
	IF @IdAceptacion > 0
	BEGIN

		SET @IdDocumentoProforma = (SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'PROFORMA');

		SELECT
			DS.NombreDocumento,
			DS.Extension,
			DS.Mime,
			DS.Carpeta,
			DS.Identificador,
			SAP.IdPedido,
			DS.IdDocumento,
			DS.Bucket
		FROM MM_SolicitudAceptacionPedido AS SAP
			JOIN S_Documento_S3 AS DS
				ON DS.IdDocumentoTabla = SAP.IdSolicitudAceptacionPedido
				AND DS.IdTipoDocumento = @IdDocumentoProforma
				AND DS.Activo=1 
				AND SAP.IdAceptacionPedido = @IdAceptacion
				AND SAP.IdPedido = @IdPedido

	END
	ELSE
	BEGIN

		SELECT 
			D.NombreDocumento,
			D.Extension,
			D.Mime,
			D.Carpeta,
			D.Identificador,
			RPO.IdPedido,
			D.IdDocumento,
			D.Bucket
    	FROM dbo.DEA_Documento_S3 D
    	INNER JOIN dbo.DEA_AdjuntoPO APO 
			ON D.IdDocumento = APO.IdDocumento
			AND APO.Activo = 1
   		LEFT JOIN dbo.DEA_Relacion_PR_PO RPO 
			ON APO.IdAdjuntoPO = RPO.IdAdjuntoPO
			AND RPO.Activo = 1
    	WHERE RPO.IdPedido = @IdPedido

	END

	
	
END

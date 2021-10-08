-- =============================================
-- Author:		Daniel AC
-- Create date: <18-09-18>
-- Description:	<obtiene la informacion del documento del factura ya sea xml o pdf>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_DEA_GetDocumentoPO_V2]

@IdProveedor INT,
@IdUsuario INT,
@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT D.NombreDocumento,D.Extension,D.Mime,D.Carpeta,
	CASE WHEN D.creadoel > '20210928' and D.creadoel < '20210929' then UPPER(D.Identificador)
		ELSE D.Identificador	END Identificador, 
	RPO.IdPedido,ISNULL(RPO.PO,'') AS PO 
	FROM dbo.DEA_Documento_S3 D
	INNER JOIN dbo.DEA_AdjuntoPO APO ON APO.IdDocumento=D.IdDocumento
 	LEFT   JOIN dbo.DEA_Relacion_PR_PO RPO 
	ON RPO.PO= APO.ID_PO
	AND RPO.IdAdjuntoPO=APO.IdAdjuntoPO
	WHERE RPO.IdPedido=@IdPedido
	AND D.Activo=1

END

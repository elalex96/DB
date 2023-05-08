-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDocumentosCargadosDG]
@IdProveedor int,
@IdTipoDocumento int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  SELECT D.IdTipoDocSG, CD.DocSistemaGestion
FROM PV_SistemaGestion D 
INNER JOIN PV_DocSistemGestion CD ON CD.IdDocSistemaGestion = D.IdTipoDocSG
WHERE D.IdProveedor = @IdProveedor and D.IdTipoDocSG = @IdTipoDocumento AND D.Activo=1

END


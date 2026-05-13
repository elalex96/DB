-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Se comento la columna de documentos a  ''
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaSGProveedor] 
	-- Add the parameters for the stored procedure here
	@idProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SG.IdSistemaGestion, DSG.DocSistemaGestion, SG.NombreCertificacion,'' AS  Documento, Activo
FROM PV_SistemaGestion SG
INNER JOIN PV_DocSistemGestion AS DSG ON DSG.IdDocSistemaGestion = SG.IdTipoDocSG
WHERE SG.IdProveedor =@idProveedor AND SG.Activo = 1 
END

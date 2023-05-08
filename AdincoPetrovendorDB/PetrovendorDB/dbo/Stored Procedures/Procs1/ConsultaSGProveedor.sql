-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ConsultaSGProveedor] 
	-- Add the parameters for the stored procedure here
	@idProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SG.IdSistemaGestion, DSG.DocSistemaGestion, SG.NombreCertificacion, Documento, Activo
FROM PV_SistemaGestion SG
INNER JOIN PV_DocSistemGestion AS DSG ON DSG.IdDocSistemaGestion = SG.IdTipoDocSG
WHERE SG.IdProveedor =@idProveedor AND SG.Activo = 1 
END


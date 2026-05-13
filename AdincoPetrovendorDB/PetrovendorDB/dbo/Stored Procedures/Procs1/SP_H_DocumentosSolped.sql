-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_H_DocumentosSolped
	-- Add the parameters for the stored procedure here
	@IDSOLPED INT
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		-- Insert statements for procedure here
		SELECT	NombreDoc, Documento
		FROM	dbo.MM_DocumentosSolPed
		WHERE
				IdSolPed = @IDSOLPED
				AND Activo = 1
	END
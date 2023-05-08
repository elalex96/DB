-- =============================================
-- Author:		Alexander Gomez
-- Create date: 31/10/2018
-- Description:	Consultar Documentos de Soporte de la PRE-SES
-- =============================================
CREATE procedure [dbo].[SP_MPY_DocumentosSoportePRESES]
	-- Add the parameters for the stored procedure here
	@IdPRESES INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT
	IdDocumento,--0
	NombreDoc
	FROM Adinco.dbo.MPY_DocumentosPRESES
	WHERE IdTipoDocumento = 2
		AND IdPRESES = @IdPRESES
	
END

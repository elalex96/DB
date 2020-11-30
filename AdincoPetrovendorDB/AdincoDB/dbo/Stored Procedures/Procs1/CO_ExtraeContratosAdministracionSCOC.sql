-- =============================================
-- Author:	Reyna Olvera
-- Create date: 10/08/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraeContratosAdministracionSCOC]--10061,10010
	-- Add the parameters for the stored procedure here
	@idUsuario INT,
	@idcontrato INT 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @idContratista INT;

	SELECT @idContratista=IdContratista FROM dbo.CO_Contrato WHERE IdContrato=@idcontrato; 
	SELECT idContrato,NumeroContrato FROM  CO_Contrato 
	WHERE IdContratista=@idContratista

	
END


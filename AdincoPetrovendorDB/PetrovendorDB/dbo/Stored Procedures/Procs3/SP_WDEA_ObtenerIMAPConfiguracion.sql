-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/08/2021>
-- Description:	<datos de conexion de correo para AX>
-- =============================================
CREATE PROCEDURE [dbo].[SP_WDEA_ObtenerIMAPConfiguracion]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	'1003' AS IdServidorIMAP,
	'outlook.office365.com' AS ServidorIMAP,
	'interfasewdea@adinco.mx' AS Email,
	'Kuc04168' AS Password,
	'993' AS Puerto,
	GETDATE() AS CreadoEl

END
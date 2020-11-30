-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/11/2019>
-- Description:	<datos de conexion de correo para AX>
-- =============================================
create PROCEDURE [dbo].[SP_AX_ObtenerIMAPConfiguracion]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	'1002' AS IdServidorIMAP,
	'imap-mail.outlook.com' AS ServidorIMAP,
	'carso@adinco.mx' AS Email,
	'Cadinco2019' AS Password,
	'993' AS Puerto,
	GETDATE() AS CreadoEl

END

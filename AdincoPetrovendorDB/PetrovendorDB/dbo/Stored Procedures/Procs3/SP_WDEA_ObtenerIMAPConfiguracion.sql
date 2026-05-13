---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author:		<Alexander Gomez>
-- Create date: <25/08/2021>
-- Description:	<datos de conexion de correo para AX>
-- =============================================
CREATE PROCEDURE [dbo].[SP_WDEA_ObtenerIMAPConfiguracion]
AS
BEGIN
	SET NOCOUNT ON;

	/*CONFIGURACIÓN PR */
	--SELECT 
	--'1003' AS IdServidorIMAP,
	--'outlook.office365.com' AS ServidorIMAP,
	--'interfasewdea@adinco.mx' AS Email,
	--'Kuc04168' AS Password,
	--'993' AS Puerto,
	--GETDATE() AS CreadoEl
	/*CONFIGURACIÓN DEV --> NO ENVIAR ESTA PARTE A PR */

	--SELECT 
	--'1003' AS IdServidorIMAP,
	--'outlook.office365.com' AS ServidorIMAP,
	--'notificaciones.desarrollo@adinco.mx' AS Email,
	--'Pad12361' AS Password,
	--'993' AS Puerto,
	--GETDATE() AS CreadoEl



	---TEMPORAL PRODUCTIVO
	SELECT 
	'1003' AS IdServidorIMAP,
	'outlook.office365.com' AS ServidorIMAP,
	'interfasewdea@outlook.com' AS Email,
	'Adinco2023#' AS Password,
	'993' AS Puerto,
	GETDATE() AS CreadoEl

	/*FIN */

END

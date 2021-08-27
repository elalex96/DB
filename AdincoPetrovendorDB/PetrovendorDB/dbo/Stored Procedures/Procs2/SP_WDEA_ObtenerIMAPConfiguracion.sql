USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_AX_ObtenerIMAPConfiguracion]    Script Date: 25/08/2021 11:30:14 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
	'imap-mail.outlook.com' AS ServidorIMAP,
	'alexander.gomez@adinco.mx' AS Email,
	'XXXXX' AS Password,
	'993' AS Puerto,
	GETDATE() AS CreadoEl

END

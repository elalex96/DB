-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultarDominio] 
	-- Add the parameters for the stored procedure here
	@IDENTIFICADOR INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT Url FROM TA_Dominios (NOLOCK) WHERE Identificador = @IDENTIFICADOR AND Activo = 1 AND IdServidor = @IDENTIFICADOR

END
/****** Object:  StoredProcedure [dbo].[EN_EliminacionFormatosPemex]    Script Date: 09/02/2019 12:17:00 a. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date:20181124
-- Description:	Eliminacion de Formatos para pemex, por rehabilitacion de calculo
-- =============================================
CREATE PROCEDURE [dbo].[EN_EliminacionFormatosParaGenerarConFirma]
	-- Add the parameters for the stored procedure here
	@idDocumentoFormato int,
	@idContrato int=0,
	@idUsuario int=0
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @mes DATE, @idContratoF INT;
		SELECT @mes=MesReporte,@idContratoF=idContrato  FROM dbo.SCOC_FormatoAmazon WHERE FormatoAmazonID=@idDocumentoFormato;


	DELETE FROM dbo.SCOC_FormatoAmazon WHERE FormatoAmazonID=@idDocumentoFormato
	

END


-- =============================================
-- Author:		Reyna Olvera
-- Create date:20181124
-- Description:	Eliminacion de Formatos para pemex, por rehabilitacion de calculo
-- =============================================
CREATE PROCEDURE [dbo].[EN_EliminacionFormatosPemex]
	-- Add the parameters for the stored procedure here
	@idDocumentoFormato int,
	@idContrato int=0,
	@idUsuario int=0
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @mes DATE, @idContratoF INT;
		SELECT @mes=MesReporte,@idContratoF=idContrato  FROM dbo.SCOC_FormatoAmazon WHERE FormatoAmazonID=@idDocumentoFormato;

	UPDATE dbo.SCOC_EnvioNotificacion 
	SET AprobadoSCOC=0,EnviadoContratista=0,AprobadoRepPEP=0, idEstatus=10000
	WHERE MesReporte=@mes AND idContrato=@idContratoF;

	DELETE FROM dbo.SCOC_FormatoAmazon WHERE FormatoAmazonID=@idDocumentoFormato
	

END

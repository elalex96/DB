-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <27/04/2020>
-- Description:	<Consultar correos relacionados con el envio de archivos para dea>
-- =============================================
create PROCEDURE [dbo].[SP_DEA_VerificacionEnvioCorreos] 
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT,
	@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CORREOSENVIADOS INT;
	--SE OBTIENE LA PO
	DECLARE @PONUMBER NVARCHAR(2000) = (SELECT TOP 1 
											ISNULL(RPO.PO,'') AS PO 
										FROM dbo.DEA_Documento_S3 D
											INNER JOIN dbo.DEA_AdjuntoPO APO 
												ON APO.IdDocumento=D.IdDocumento
 											LEFT JOIN dbo.DEA_Relacion_PR_PO RPO 
												ON RPO.PO= APO.ID_PO
												AND RPO.IdAdjuntoPO=APO.IdAdjuntoPO
										WHERE RPO.IdPedido = @IdPedido
											AND D.Activo=1);
	--SE OBTIENE EL ASUNTO DEL CORREO EN PLANTILLA
	DECLARE @ASUNTOCORREOSDEA NVARCHAR(2000) = (SELECT Asunto FROM dbo.TA_Correo WHERE IdCorreo = 87);
	--SE ARMA EL ASUNTO DEL CORREO QUE SE DEBIO ENVIAR
	--SI VALIDA SI TIENE PO O NO
	IF @PONUMBER = ''
	BEGIN

	    SET @ASUNTOCORREOSDEA = (REPLACE(@ASUNTOCORREOSDEA,'##NO_PO##',' - Aceptacion No.' + CAST(@IdAceptacionPedido AS NVARCHAR)));

	END
	ELSE
	BEGIN
	    
		SET @ASUNTOCORREOSDEA = (REPLACE(@ASUNTOCORREOSDEA,'##NO_PO##',@PONUMBER + ' - Aceptacion No.' + CAST(@IdAceptacionPedido AS NVARCHAR)));

	END
	
	--SE OBITENE EL NUMERO DE CORREOS ENVIADOS
	SET @CORREOSENVIADOS = (SELECT COUNT(1) FROM Adinco.dbo.S_Notificacion WHERE Asunto = @ASUNTOCORREOSDEA);

	SELECT ISNULL(@CORREOSENVIADOS,0) AS CORREOSENVIADOS;

END

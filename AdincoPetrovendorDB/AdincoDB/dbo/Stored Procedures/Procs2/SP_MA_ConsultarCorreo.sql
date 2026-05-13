
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 29-01-18
-- Description:Regresa el tipo de correo solicitado
			
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_MA_ConsultarCorreo] 
	-- Add the parameters for the stored procedure here
	 @IdCorreo INT,
	 @IdDominio INT,
	 @IdContrato INT = 0,
	 @IdUsuario INT =0,
	 @FechaRegistro DATETIME = '29-01-2018 00:00'
	
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @DOMINIO NVARCHAR(250)

	SELECT @DOMINIO =Dominio
	FROM MA_DominioCorreo  
	WHERE IdDominio = @IdDominio

    -- Insert statements for procedure here
	 SELECT HTML,Asunto,CuentaRegistro, Contrasena, SMTP, Puerto,ISNULL(BBC,''), @DOMINIO AS Dominio
	 FROM MA_Correo AS C
	 INNER JOIN MA_ServidorDeCorreo AS S ON S.IdServidor=C.IdServidor
	 WHERE IdCorreo = @IdCorreo 

END




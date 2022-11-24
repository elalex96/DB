-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ValidarCorreoContacto]
@IdContacto INT,
@IdProveedor INT,
@Correo NVARCHAR(300)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ExisteCorreo INT = (SELECT COUNT(Email) FROM dbo.S_Contacto_PA WHERE  Email = @Correo AND IsEliminado = 0)

	IF(@ExisteCorreo > 0)
	BEGIN
		IF(@IdContacto = 0)
	BEGIN
	SELECT 'NO_DISPONIBLE'
    END
    

	DECLARE @CorreoActual NVARCHAR(100) = (SELECT Email FROM dbo.S_Contacto_PA WHERE IdContacto = @IdContacto AND IsEliminado = 0)
	IF(@CorreoActual = @Correo)
	BEGIN
	SELECT 'CORREO_NO_CHANGE'
    END
	IF(@CorreoActual != @Correo)
    BEGIN
	DECLARE @CorreoExistente INT = (SELECT TOP 1 IdContacto FROM dbo.S_Contacto_PA WHERE Email = @Correo AND IsEliminado = 0)
	IF(@CorreoExistente != @IdContacto)
	BEGIN
	SELECT 'NO_DISPONIBLE'
    END
	 
	END
    
	 

	END
	ELSE
    BEGIN
	SELECT 'DISPONIBLE'
    END 

END


/****** Object:  StoredProcedure [dbo].[SP_ConsultarCorreoCuentaBancariaCliente]    Script Date: 11/9/2017 10:05:52 AM ******/
SET ANSI_NULLS ON

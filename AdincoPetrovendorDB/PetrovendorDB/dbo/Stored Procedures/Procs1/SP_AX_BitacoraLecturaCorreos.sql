-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <06/12/2019>
-- Description:	<Registro de bitacora de lectura de correos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AX_BitacoraLecturaCorreos]
	-- Add the parameters for the stored procedure here
	@Asunto NVARCHAR(MAX),
	@CantidadArchvios INT,
	@FechaLectura DATETIME,
	@FechaEnvio DATETIME,
	@ServicioOperadora NVARCHAR(MAX),
	@CorreoEnviado NVARCHAR(MAX),
	@Para NVARCHAR(MAX),
	@Error BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO dbo.AX_BitacoraLecturaCorreos
	(
	    Asunto,
	    CantidadArchivos,
	    FechaLectura,
	    FechaEnvio,
	    EnviadoPor,
	    ServicioOperadora,
	    FechaRegBitacora,
		RecibidoPor,
		IsError
	)
	VALUES
	(   @Asunto,       -- Asunto - nvarchar(2000)
	    @CantidadArchvios,         -- CantidadArchivos - int
	    @FechaLectura, -- FechaLectura - datetime
	    @FechaEnvio, -- FechaEnvio - datetime
	    @CorreoEnviado,       -- EnviadoPor - nvarchar(1000)
	    @ServicioOperadora,       -- ServicioOperadora - nvarchar(100)
	    GETDATE(), -- FechaRegBitacora - datetime
		@Para,
		@Error
	    )
END

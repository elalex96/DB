-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 12/SEPTIEMBRE/2017
-- Description:	Registra esattus de correos enviados o no enviados

-- =============================================
CREATE PROCEDURE  [dbo].[SP_TA_AgregarBitacoraCorreo] 
	-- Add the parameters for the stored procedure here
		
	@IdDocumento int,
	@IdProveedorActual int=NULL,
	@IdUsuarioActual int=NULL,
	@Detalle nvarchar(MAX),
	@Enviado bit,
	@Correo nvarchar(300),
	@IdUsuarioReceptor int = null

		 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	IF @IdUsuarioReceptor = 0
	SET @IdUsuarioReceptor = NULL

	IF @IdDocumento = 0
	SET @IdDocumento = NULL

	IF @IdUsuarioActual = 0
	SET @IdUsuarioActual = NULL

	IF @IdProveedorActual = 0
	SET @IdProveedorActual = NULL
	

	INSERT INTO [dbo].[TA_BitacoraCorreo](
	[IdDocumento],
	[Detalle],
	[Correo],
	[Enviado],
	[FechaEnvio],
	[IdUsuarioEnvio],
	[IdProveedorEnvio],
	[IdUsuarioReceptor]
	)VALUES(
	@IdDocumento,
	@Detalle,
	@Correo,
	@Enviado,
	getdate(),
	@IdUsuarioActual,
	@IdProveedorActual,
	@IdUsuarioReceptor
	)

END



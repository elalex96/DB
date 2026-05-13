-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 10/Julio/2017
-- Description:	Permite agregar Registro de invitaciones para peticiones de oferta
-- Update se cambio retorno al Id de la invitacion
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 07/10/2019
-- Description:	se agrego el parametro de cotizacion restringida
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_MM_AgregarDetalleInvitacionPeticionOferta] 
	-- Add the parameters for the stored procedure here
		
	@IdSolicitudPedido int,
	@IdProveedorInvitado int,
	@RazonNoInvitacion nvarchar(max),
	@CreadoPor int, 
	@IdPeticionOferta int,
	@CodigoActivacion nvarchar(max),
	@InvitacionPorCorreo bit,
	@CorreoInvitacion nvarchar(max),
	@InvitacionPorMaterial bit,
	@Invitado bit,
	@CorreoEnviado bit,
	@IdProveedorActual INT,
	@CotizacionRestringida BIT = NULL

		 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @RazonNoInvitacionF NVARCHAR(MAX) 
		DECLARE @IdPeticionOfertaF INT 
		DECLARE @CodigoActivacionF  NVARCHAR(MAX) 
		DECLARE @IdProveedorInvitadoF INT

		IF @RazonNoInvitacion =''
		SET @RazonNoInvitacionF =NULL
		ELSE
		SET @RazonNoInvitacionF= @RazonNoInvitacion
		

		IF @IdPeticionOferta =0
		SET @IdPeticionOfertaF =NULL
		ELSE
		SET @IdPeticionOfertaF= @IdPeticionOferta

		IF @CodigoActivacion = ''
		 SET @CodigoActivacionF = NULL
		 ELSE 
		SET @CodigoActivacionF = @CodigoActivacion

		IF @IdProveedorInvitado= 0
		SET @IdProveedorInvitadoF = NULL
		ELSE 
		SET @IdProveedorInvitadoF = @IdProveedorInvitado
		
		INSERT INTO MM_InvitacionPeticionOferta
		([Fecha],
		[CorreoEnviado], 
		[IdSolicitudPedido], 
		[IdProveedorInvitado], 
		[CreadoPor], 
		[IdPeticionOferta], 
		[InvitacionPorMaterial],
		[CorreoInvitacion],
		[Invitado],
		[RazonNoInvitacion],
		[InvitacionPorCorreo],
		[CodigoActivacion],
		[Activo],
		[IdProveedorInvito],
		[CotizacionRestringida])
		VALUES 
		(
		GETDATE(),
		@CorreoEnviado,
		@IdSolicitudPedido,
		@IdProveedorInvitadoF,
		@CreadoPor,
		@IdPeticionOfertaF,
		@InvitacionPorMaterial,
		@CorreoInvitacion,
		@Invitado,
		@RazonNoInvitacionF,
		@InvitacionPorCorreo,
		@CodigoActivacionF,
		1,
		@IdProveedorActual,
		@CotizacionRestringida
		)

		SELECT @@IDENTITY AS Response
END

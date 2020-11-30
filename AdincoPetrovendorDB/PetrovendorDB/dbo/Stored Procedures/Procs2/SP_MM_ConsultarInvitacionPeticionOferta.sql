-- =============================================
-- Author:	ABEL RIVERA
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
-- Author:	Alexander Gomez
-- Create date: <07/10/2019>
-- Description:	<Agregado de la cotizacion restringida por cotizacion>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarInvitacionPeticionOferta] --'alexander.gomez@adinco.mx','6XK9U','2019-10-07 09:52:18.920'
@Correo nvarchar(350),
@CodigoActivacion nvarchar(150),
@FechaActual datetime 

AS
DECLARE @FechaRegistro datetime
DECLARE @Vigencia int
DECLARE @FechaLimite datetime
DECLARE @IdSolPed int
DECLARE @EstatusInvitacion BIT
DECLARE @CotizacionRestringida BIT
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SET @EstatusInvitacion = (SELECT IPO.[Activo]
		FROM [dbo].[MM_InvitacionPeticionOferta] IPO
		WHERE IPO.[CorreoInvitacion] = @Correo AND IPO.[CodigoActivacion] = @CodigoActivacion);

	SET @CotizacionRestringida = (SELECT IPO.CotizacionRestringida
		FROM [dbo].[MM_InvitacionPeticionOferta] IPO
		WHERE IPO.[CorreoInvitacion] = @Correo AND IPO.[CodigoActivacion] = @CodigoActivacion);

	IF @EstatusInvitacion = 1 --- INVITACIÓN ACTIVA
	BEGIN 

		SET @IdSolPed = (SELECT IPO.[IdSolicitudPedido]
		FROM [dbo].[MM_InvitacionPeticionOferta] IPO
		WHERE IPO.[CorreoInvitacion] = @Correo AND IPO.[CodigoActivacion] = @CodigoActivacion AND IPO.Activo = 1)
		
		SET @FechaRegistro = (SELECT [FechaRegistro]
		FROM [dbo].[TA_Operacion] TAO
		WHERE TAO.[IdDocumento] = @IdSolPed AND TAO.[IdTipoOperacion] = 6)
		
		--SET @FechaLimite = (SELECT DATEADD(day,@Vigencia,@FechaRegistro))
		SET @FechaLimite = (SELECT [FechaFinalizacion]
							FROM [dbo].[TA_Operacion] TAO
							WHERE TAO.[IdDocumento] = @IdSolPed AND TAO.[IdTipoOperacion] = 6)
	

		IF @FechaActual <= @FechaLimite
			BEGIN
				SELECT @IdSolPed, ISNULL(@CotizacionRestringida,0)  --- SIGUE PROCESO DE RECUPERACIÓN DE COTIZACIÓN
			END
		ELSE
			BEGIN
				SET  @IdSolPed = 0  ---NOTIFICACIÓN  INVITACIÓN VENCIDA POR PERIODO DE TIEMPO
				SELECT @IdSolPed, ISNULL(@CotizacionRestringida,0)
			END

	END 
	ELSE
	BEGIN   --- INVITACION INACTIVA 
		
		IF @EstatusInvitacion is null
			BEGIN 
				SET   @IdSolPed = -2 --NOTIFICACIÓN DE CODIGO NO EXISTE
				SELECT @IdSolPed, ISNULL(@CotizacionRestringida,0)
			END
		ELSE
		BEGIN 
			SET   @IdSolPed = -1 --NOTIFICACIÓN QUE ESTA COTIZACIÓN YA HA SIDO RECUPERADA
			SELECT @IdSolPed, ISNULL(@CotizacionRestringida,0)	
		END 	
	END 

	

END

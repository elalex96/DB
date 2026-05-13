-- =============================================
-- Author:		Abel Rivera
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActualizarEstatusInvatacionPeticionOferta]
@IdSolPed int,
@IdPeticionOferta int,
@Correo nvarchar(350),
@CodigoActivacion nvarchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	UPDATE [dbo].[MM_InvitacionPeticionOferta]
	SET 
	[IdPeticionOferta] = @IdPeticionOferta,
	[CodigoActivo] = 1,
	[FechaActualizacion] = GETDATE(),
	[Activo] = 0
	WHERE [IdSolicitudPedido] = @IdSolPed AND [CorreoInvitacion]=@Correo AND [CodigoActivacion]= @CodigoActivacion

	SELECT @@IDENTITY

END


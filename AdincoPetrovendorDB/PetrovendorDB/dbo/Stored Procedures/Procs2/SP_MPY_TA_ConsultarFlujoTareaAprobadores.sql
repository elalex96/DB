
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 27-03-17
-- Description:	Regresa los aprobadores de un flujo de tarea				
-- =============================================
-- Author:		Jose Roman
-- Create date: 19-09-2018
-- Description:	Se consultan los usuarios con 				
-- =============================================

	CREATE  PROCEDURE [dbo].[SP_MPY_TA_ConsultarFlujoTareaAprobadores]
	-- Add the parameters for the stored procedure here
	 @IdAceptacionPedido INT 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 --SELECT IdAprobador_FI, Nombre, Correo 
	 --FROM dbo.MPY_FI_Aprobadores
	 --WHERE IdAceptacionPedido = @IdAceptacionPedido

	 SELECT 
		 US.IdUsuario, 
		 US.Nombre, 
		 US.Correo,
		 US.IdTipoUsuario
	FROM dbo.MPY_MM_AceptacionPedido ap 
	LEFT JOIN Adinco.dbo.CO_Contratista AS CO ON CO.IdContratista = ap.IdProveedor
	LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE Modern_Spanish_CI_AS = CO.RFC COLLATE Modern_Spanish_CI_AS
	LEFT JOIN dbo.S_UsuarioProveedor AS UP ON UP.IdProveedor = PR.IdProveedor
	LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = UP.IdUsuario AND (US.IdTipoUsuario = 3 OR US.IdTipoUsuario = 4)
	WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
		AND US.Activo = 1
		AND ISNULL(US.IsEliminado, 0) = 0
		AND US.IdUsuario IS NOT NULL
	GROUP BY US.IdUsuario, US.Nombre, US.Correo,US.IdTipoUsuario

END


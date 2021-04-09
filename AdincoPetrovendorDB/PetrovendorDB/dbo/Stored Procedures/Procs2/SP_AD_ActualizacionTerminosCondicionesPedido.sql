USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_AD_ActualizacionTerminosCondicionesPedido]    Script Date: 09/04/2021 11:25:19 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/04/2021>
-- Description:	<Actualizacion de los terminos y condiciones>
-- =============================================
ALTER PROCEDURE [dbo].[SP_AD_ActualizacionTerminosCondicionesPedido]
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdTerminosCondiciones INT,
	@Responsable NVARCHAR(200),
	@Justificacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IDPEDIDOS INT = (SELECT TOP 1 ISNULL(PS.IdPedido,0)
								FROM dbo.TA_Operacion AS OP
								LEFT JOIN dbo.MM_SolicitudPedido AS SP ON OP.IdDocumento = SP.IdSolicitudPedido
								LEFT JOIN dbo.MM_Pedido AS P ON SP.IdSolicitudPedido = P.IdSolicitudPedido AND OP.NoVersion = P.Version
								LEFT JOIN dbo.MM_Pedidos AS PS ON P.IdPedido = PS.IdIdentificador AND  PS.IdTipoPedido IN (2,4,6)
								WHERE OP.IdOperacion = @IdOperacion
								);
	DECLARE @IDPEDIDO INT = (SELECT TOP 1 ISNULL(P.IdPedido,0)
								FROM dbo.TA_Operacion AS OP
								LEFT JOIN dbo.MM_SolicitudPedido AS SP ON OP.IdDocumento = SP.IdSolicitudPedido
								LEFT JOIN dbo.MM_Pedido AS P ON SP.IdSolicitudPedido = P.IdSolicitudPedido AND OP.NoVersion = P.Version
								WHERE OP.IdOperacion = @IdOperacion
								);
	DECLARE @IDTERMINO INT = (SELECT TOP 1 TCO.IdOperacionTC
							  FROM TA_TerminosCondicionesOperacion TCO
							 INNER JOIN TA_Operacion O 
								ON TCO.IdOperacion = O.IdOperacion 
							INNER JOIN MM_Pedido PIN 
								ON O.IdDocumento = PIN.IdSolicitudPedido
							INNER JOIN TC_TerminosYCondicionesDocV2 TYC 
								ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
							WHERE PIN.IdPedido = @IDPEDIDO);
	DECLARE @IDTERMINONOMBRENUEVO NVARCHAR(MAX) = (SELECT TOP 1 Nombre FROM dbo.TC_TerminosYCondicionesDocV2 WHERE IdTerminosYCondiciones = @IdTerminosCondiciones);
	DECLARE @IDTERMINONOMBREANT NVARCHAR(MAX) = (SELECT TOP 1 TYC.Nombre 
													FROM TA_TerminosCondicionesOperacion TCO
													INNER JOIN TA_Operacion O 
														ON TCO.IdOperacion = O.IdOperacion 
													INNER JOIN MM_Pedido PIN 
														ON O.IdDocumento = PIN.IdSolicitudPedido
													INNER JOIN TC_TerminosYCondicionesDocV2 TYC 
														ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
													WHERE PIN.IdPedido = @IDPEDIDO);
	DECLARE @DESCRIPCIONHISTORIAL NVARCHAR(MAX) = (@Responsable + ' cambio los terminos y condiciones(' + ISNULL(@IDTERMINONOMBREANT,'Sin terminos') +') a ' + @IDTERMINONOMBRENUEVO + ' del pedido No.' + CAST(@IDPEDIDOS AS nvarchar));
	

	INSERT INTO dbo.AD_HistorialActualizacionPedido(
		IdPedido,
		ComentarioEditado,
		Responsable,
		TipoEdicion,
		Descripcion,
		Fecha
	) 
	VALUES
	(
		@IDPEDIDO,
		@Justificacion,
		@Responsable,
		'UPD_TERMINOS_CONDICIONES',
		@DESCRIPCIONHISTORIAL,
		GETDATE()
	);


	IF ISNULL(@IDTERMINO,0) > 0
	BEGIN
		UPDATE dbo.TA_TerminosCondicionesOperacion
		SET IdTerminosYCondiciones = @IdTerminosCondiciones
		WHERE IdOperacionTC = @IDTERMINO;
	END
	ELSE
	BEGIN
		INSERT INTO dbo.TA_TerminosCondicionesOperacion 
		(IdOperacion,IdTerminosYCondiciones)
		VALUES
		(@IdOperacion,@IdTerminosCondiciones);

	END

	SELECT 'SUCCESS'

END

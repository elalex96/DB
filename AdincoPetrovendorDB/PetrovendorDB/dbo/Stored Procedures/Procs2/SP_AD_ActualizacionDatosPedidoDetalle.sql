USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_AD_ActualizacionDatosPedidoDetalle]    Script Date: 08/04/2021 01:31:46 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <31/03/2021>
-- Description:	<Actualizacion de los dias de credito desde consola>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ActualizacionDatosPedidoDetalle] --41097,60,'','','UPD_DIAS_CREDITO'
	-- Add the parameters for the stored procedure here
	@IdPedidoDetalle INT,
	@DiasCredito INT,
	@ComentarioEdicion NVARCHAR(MAX),
	@EditadoPor NVARCHAR(100),
	@Tipo NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @DIASDECREDITOANT INT = (SELECT ISNULL(DiasCredito,0) FROM MM_PedidoDetalle WHERE IdPedidoDetalle = @IdPedidoDetalle);
	DECLARE @DESCRIPCIONHISTORIAL NVARCHAR(MAX) = (@EditadoPor + ' cambio los dias de credito de ' + CAST(@DIASDECREDITOANT AS nvarchar) +' a ' + CAST(@DiasCredito AS nvarchar) + ' dias de la partida No.' + CAST(@IdPedidoDetalle AS nvarchar));
	DECLARE @IDPEDIDO INT = (SELECT ISNULL(IdPedido,0) FROM MM_PedidoDetalle WHERE IdPedidoDetalle = @IdPedidoDetalle);

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
		@ComentarioEdicion,
		@EditadoPor,
		@Tipo,
		@DESCRIPCIONHISTORIAL,
		GETDATE()
	);
	
	UPDATE MM_PedidoDetalle
	SET DiasCredito = @DiasCredito,
		ComentarioEdicion = @ComentarioEdicion,
		EditadoPorDC  = @EditadoPor
	WHERE IdPedidoDetalle = @IdPedidoDetalle;

END

-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/03/2018
-- Description:	Eliminado logico de una factura y cancelacion de la tarea de esa factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarFacturaCompraDirecta]
	-- Add the parameters for the stored procedure here
	@IdPedido INT,
	@Comentario NVARCHAR(MAX),
	@IdUsuario INT,
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IdFactura INT;
	DECLARE @IdOperacion INT;

	SET @IdFactura = (SELECT IdIdentificador FROM dbo.MM_Pedidos WHERE IdPedido = @IdPedido AND IdProveedorCliente = @IdProveedor)

	SET @IdOperacion = (SELECT IdOperacion FROM dbo.TA_Operacion WHERE IdDocumento = @IdFactura)

    -- Insert statements for procedure here
	UPDATE dbo.FI_Factura 
		SET IsEliminado = 1,
			ComentarioEliminado = @Comentario,
			EliminadoPor = @IdUsuario,
			EliminadoEL = GETDATE()
	WHERE IdFactura = @IdFactura

	UPDATE dbo.TA_Operacion 
	SET IdEstatusOperacion = 10,
		IdEstadoFlujo = 9
		WHERE IdDocumento = @IdFactura

	UPDATE dbo.TA_Tarea
	SET IdEstatus = 10
	WHERE IdOperacion = @IdOperacion


	DECLARE @UUID NVARCHAR(MAX) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IdFactura)

	INSERT INTO dbo.FI_FacturaEliminada
	(
	    IdFactura,
	    FechaEliminada,
	    EliminadaPor,
	    UUID
	)
	VALUES
	(   @IdFactura,         -- IdFactura - int
	    GETDATE(), -- FechaEliminada - datetime
	    @IdUsuario,         -- EliminadaPor - int
	    @UUID        -- UUID - nvarchar(max)
	    )

	SELECT IsEliminado FROM dbo.FI_Factura WHERE IdFactura = @IdFactura
END

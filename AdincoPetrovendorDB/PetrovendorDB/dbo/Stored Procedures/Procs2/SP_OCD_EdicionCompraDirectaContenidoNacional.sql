-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/04/2020>
-- Description:	<Edicion del cn de compra directa>
-- =============================================
CREATE PROCEDURE [dbo].[SP_OCD_EdicionCompraDirectaContenidoNacional]
	-- Add the parameters for the stored procedure here
	@IdCDCN INT,
	@IdContrato INT,
	@IdProveedor INT,
	@IdFactura INT,
	@IdPedido INT,
	@DescripcionBienesServicios NVARCHAR(MAX),
	@ValorFactura FLOAT,
	@PCN FLOAT,
	@IdActividadBS INT,
	@ClasificacionSH INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	IF @IdActividadBS = 0
	BEGIN
	    SET @IdActividadBS = NULL;
	END
	    
		UPDATE dbo.CN_CompraDirecta
		SET IdContrato = @IdContrato,
			IdProveedor = @IdProveedor,
			IdFactura = @IdFactura,
			IdPedido = @IdPedido,
			DescripcionBienesServicios = @DescripcionBienesServicios,
			ValorFactura = @ValorFactura,
			PCN = @PCN,
			IdActividadBS = @IdActividadBS,
			ClasificacionSH = @ClasificacionSH,
			ModificadoEl = GETDATE(),
			ModificadoPor = @IdUsuario
		WHERE IdCDCN = @IdCDCN;


	SELECT @IdCDCN AS RegistroActualizado;

END

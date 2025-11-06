USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_OCD_GuardadoCNCompraDirecta') IS NOT NULL
BEGIN
DROP PROCEDURE SP_OCD_GuardadoCNCompraDirecta;
END
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/04/2020>
-- Description:	<Guardado del detalle de cn de compra directa>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <05/1/2025>
-- Description:	<Se contempla la actualización del rubor y pcn para el registro del gasto>
-- =============================================
CREATE PROCEDURE [dbo].[SP_OCD_GuardadoCNCompraDirecta]
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	@IdProveedor INT,
	@IdContrato INT,
	@IdUsuario INT,
	@ConceptosCN ConceptosCNCompraDirecta READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @TOTALINSERTADOS INT = (SELECT COUNT(1) FROM @ConceptosCN);

	DECLARE @IDPEDIDO INT = (SELECT IdPedido FROM dbo.MM_Pedidos WHERE IdIdentificador = @IdFactura AND IdTipoPedido = 1 AND IdProveedorCliente = @IdProveedor);


	INSERT INTO dbo.CN_CompraDirecta
	(
	    IdContrato,
	    IdProveedor,
	    IdFactura,
		IdPedido,
	    DescripcionBienesServicios,
	    ValorFactura,
	    PCN,
	    IdActividadBS,
	    ClasificacionSH,
	    Activo,
		CreadoPor,
		CreadoEl
	)
	SELECT
		@IdContrato,
		@IdProveedor,
		@IdFactura,
		@IDPEDIDO,
		CNC.DescripcionBienesServicios,
		CNC.ValorFactura,
		CNC.PCN,
		CASE 
			WHEN CNC.IdActividadBS = 0 THEN NULL
			ELSE CNC.IdActividadBS
		END,
		CNC.ClasificacionSH,
		1,
		@IdUsuario,
		GETDATE()
	FROM @ConceptosCN AS CNC;

	IF @@ROWCOUNT = @TOTALINSERTADOS
	BEGIN

		--SE ACTUALIZA CO_Registro
		UPDATE dbo.CO_Registro 
		SET dbo.CO_Registro.IdGastoRubro = dbo.CN_CompraDirecta.ClasificacionSH,
			dbo.CO_Registro.PCN = dbo.CN_CompraDirecta.PCN
		FROM dbo.CO_Registro
		INNER JOIN dbo.CN_CompraDirecta ON dbo.CO_Registro .IdFactura = dbo.CN_CompraDirecta.IdFactura
		WHERE dbo.CO_Registro.IdFactura = @IdFactura;
	    
		SELECT 'true' AS REGISTROSGUARDADOS

	END
	ELSE
	BEGIN
	    
		SELECT 'false' AS REGISTROSGUARDADOS

	END

END

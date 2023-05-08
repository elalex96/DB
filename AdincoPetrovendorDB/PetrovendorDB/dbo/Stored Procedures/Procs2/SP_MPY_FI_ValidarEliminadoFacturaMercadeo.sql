-- =============================================
-- Author:		Alexander Gomez
-- Create date: 22/03/2018
-- Description: Validacion para eliminar la factura en mercadeo
-- =============================================
CREATE procedure [dbo].[SP_MPY_FI_ValidarEliminadoFacturaMercadeo] 
	-- Add the parameters for the stored procedure here
	@IdAceptacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdFactura INT = (SELECT AF.IdFactura FROM dbo.MPY_MM_AceptacionPedido AS AP
									LEFT JOIN dbo.MPY_MM_AceptacionFactura AS AF ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
									LEFT JOIN dbo.FI_Factura AS FAC ON FAC.IdFactura = AF.IdFactura
								WHERE AP.IdAceptacionPedido = @IdAceptacion)

	DECLARE @UUID NVARCHAR(MAX) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IdFactura)

	DECLARE @IDFACADINCO INT = (SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID)

	IF @IDFACADINCO > 0
	BEGIN
		DECLARE @EXISTEGASTO INT = (SELECT COUNT(IdRegistro)  FROM Adinco.dbo.CO_Registro WHERE IdFactura = @IDFACADINCO)

		IF @EXISTEGASTO > 0
		BEGIN
			SELECT 'GASTOS RELACIONADOS CON LA FACTURA'
		END
		ELSE
		BEGIN
			DECLARE @EXISTETRANSFER INT = (SELECT COUNT(IdTransferFactura) FROM Adinco.dbo.FI_TransferFactura WHERE IdFactura = @IDFACADINCO)

			IF @EXISTETRANSFER > 0
			BEGIN
				SELECT 'TRANSFERENCIAS RELACIONADAS CON LA FACTURA' 
			END
			ELSE
			BEGIN
				DELETE FROM Adinco.dbo.FI_CFDIConcepto WHERE IdFactura = @IDFACADINCO
				DELETE FROM Adinco.dbo.FI_Documento WHERE IdFactura = @IDFACADINCO
				DELETE FROM Adinco.dbo.FI_Factura WHERE IdFactura = @IDFACADINCO 
				SELECT 'ELIMINAR FACTURA LOGICA PETROVENDOR-FACTURA ELIMINADA DE ADINCO'
			END
		END
	END
	ELSE
	BEGIN
		SELECT 'ELIMINAR FACTURA LOGICA PETROVENDOR'
	END
END

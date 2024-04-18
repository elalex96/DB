USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ValidarEliminadoFacturaMercadeo'
)
    DROP PROCEDURE SP_FI_ValidarEliminadoFacturaMercadeo;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 22/03/2018
-- Description: Validacion para eliminar la factura en mercadeo
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 31/05/2018
-- Description: Cambio en al logica de validacion
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 17-04-2024
-- Description: Se agrega la validacion del registro markup
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidarEliminadoFacturaMercadeo] --26430
	-- Add the parameters for the stored procedure here
	@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @IDFACTURA INT = (SELECT IdFactura FROM dbo.MM_AceptacionFactura WHERE IdAceptacionPedido = @IdAceptacionPedido);
	DECLARE @UUID NVARCHAR(MAX) = (SELECT UUID FROM dbo.FI_Factura WHERE IdFactura = @IDFACTURA);
	DECLARE @IDFACADINCO INT = (SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUID);
	DECLARE @GASTO INT = (SELECT TOP 1 IdRegistro FROM Adinco.dbo.CO_Registro WHERE IdFactura = @IDFACADINCO);
	DECLARE @GASTO_MARKUP INT = (SELECT TOP 1 Id FROM Adinco.dbo.CO_RegistroMarkup WHERE GastoId = @GASTO);
	DECLARE @TRANSFERFACTURA INT = (SELECT COUNT(IdTransferFactura) FROM Adinco.dbo.FI_TransferFactura WHERE IdFactura = @IDFACADINCO);
	DECLARE @RESPONSE NVARCHAR(100);

	IF @IDFACADINCO IS NOT NULL
	BEGIN

		SET @RESPONSE = 'FACTURA_EN_ADINCO';

		IF ISNULL(@GASTO,0) > 0 OR ISNULL(@GASTO_MARKUP,0) > 0
		BEGIN

			SET @RESPONSE = 'FACTURA_CON_GASTO';

			IF ISNULL(@TRANSFERFACTURA,0) > 0
			BEGIN

				SET @RESPONSE = 'FACTURA_CON_TRANSFERENCIA';

			END;

		END;

	END
	ELSE
	BEGIN

		SET @RESPONSE = 'FACTURA_EN_ADINCO';
	
	END;

	SELECT @RESPONSE AS RESPONSE

END

-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/10/2021
-- Description:	Eliminado de complementos de pago en adinco y petrovendor validando las tranferencias
-- =============================================
CREATE PROCEDURE SP_MM_CP_EliminarComplementoPago
	-- Add the parameters for the stored procedure here
	@IdFactura INT,
	@IdFacturaComplementoPago INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @IdComplementoDePago INT,
		@IdPDFComplemento INT,
		@IdFacturaComplemento INT,
		@UUIDFacturaComplemento NVARCHAR(1000),
		@IdFacturaComplementoAdinco INT,
		@IdComplementoPagoAdinco INT,
		@IdDocRelacionadoAdinco INT,
		@TieneTransferencia INT;

	SELECT TOP 1
		@IdPDFComplemento = PDF.IdPDFComplemento,
		@IdFacturaComplemento = FC.IdFacturaComplemento,
		@IdComplementoDePago = CP.IdComplementoDePago,
		@UUIDFacturaComplemento = F.UUID
	FROM dbo.FI_ComplementoDePago AS CP
	JOIN FI_FacturaComplemento AS FC ON CP.IdFactura = FC.IdComplemento
	JOIN FI_PDFComplemento AS PDF ON CP.IdFactura = PDF.IdFacturaComplemento --AND PDF.Activo = 1
	JOIN FI_Factura AS F ON CP.IdFactura = F.IdFactura
	WHERE FC.IdFactura = @IdFactura AND CP.IdFactura = @IdFacturaComplementoPago;

	SET @IdFacturaComplementoAdinco = (SELECT IdFactura FROM Adinco.dbo.FI_Factura WHERE UUID = @UUIDFacturaComplemento AND Activa = 1);

	SELECT TOP 1
		@TieneTransferencia = IdTransfer
	FROM Adinco.dbo.FI_TransferFactura AS TF
	JOIN Adinco.dbo.FI_Transfer AS T ON TF.IdTransfer = T.IdTransferencia
	WHERE TF.IdFactura = @IdFacturaComplementoAdinco;

	--VALIDACION DE TRANFERENCIA
	IF @TieneTransferencia IS NULL
	BEGIN
		
		--ELIMINADO EN PETROVENDOR
		--ELIMINADO DEL COMPLEMENTO
		UPDATE FI_ComplementoDePago
		SET EliminadoEl = GETDATE(),
			EliminadoPor = @IdUsuario,
			IsEliminado = 1
		where IdComplementoDePago = @IdComplementoDePago

		--ELIMINADO DEL ARCHIVO
		UPDATE FI_PDFComplemento
		SET EliminadoEl = GETDATE(),
			EliminadoPor = @IdUsuario,
			Activo = 0
		where IdPDFComplemento = @IdPDFComplemento

		--ELIMINADO DE LA RELACION DE LA FACTURA CON EL COMPLEMENTO
		UPDATE FI_FacturaComplemento
		SET EliminadoEl = GETDATE(),
			EliminadoPor = @IdUsuario,
			IsEliminado = 1
		where IdFacturaComplemento = @IdFacturaComplemento

		--ELIMINADO DE LA FACTURA DEL COMPLEMENTO
		UPDATE FI_Factura
		SET EliminadoEl = GETDATE(),
			EliminadoPor = @IdUsuario,
			IsEliminado = 1,
			Activa = 0
		where IdFactura = @IdFacturaComplementoPago

		--ELIMINADO EN ADINCO
			DELETE Adinco.dbo.FI_CFDIConceptoImpuesto
         WHERE IdFacturaConcepto IN
         (
             SELECT IdFacturaConcepto
             FROM Adinco.dbo.FI_CFDIConcepto
             WHERE IdFactura = @IdFacturaComplementoAdinco
         );

         /**/

         DELETE Adinco.dbo.FI_CFDIConcepto
         WHERE IdFactura = @IdFacturaComplementoAdinco;

         /**/

         DELETE Adinco.dbo.FI_CFDIImpuesto
         WHERE IdFactura = @IdFacturaComplementoAdinco;

         /**/

         DELETE Adinco.dbo.FI_Documento
         WHERE IdFactura = @IdFacturaComplementoAdinco;

         /**/

         DELETE Adinco.dbo.FI_ArchivoXml
         WHERE IdFactura = @IdFacturaComplementoAdinco;

         /**/

         DELETE Adinco.dbo.FI_CPDocRelacionado
         WHERE IdComplementoDePago IN
         (
             SELECT IdComplementoDePago
             FROM Adinco.dbo.FI_ComplementoDePago
             WHERE IdFactura = @IdFacturaComplementoAdinco
         );

         /**/


         DELETE Adinco.dbo.FI_ComplementoDePago
         WHERE IdFactura = @IdFacturaComplementoAdinco;

         /**/

         DELETE Adinco.dbo.FI_CFDIRelacionados
         WHERE CFDIId = @IdFacturaComplementoAdinco;

         /**/

         DELETE Adinco.dbo.FI_PPD_MesPresentacion
         WHERE idFactura = @IdFacturaComplementoAdinco;

         /**/

         DELETE Adinco.dbo.FI_Factura
         WHERE IdFactura = @IdFacturaComplementoAdinco;
		 

		 SELECT 'COMPLEMENTO_DE_PAGO_ELIMINADO'

	END
	ELSE
	BEGIN

		SELECT 'YA_TIENE_TRANSFERENCIA'

	END
	
END

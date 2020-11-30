-- =============================================
-- Author:		Daniel Cruz
-- Create date: 08-08-17
-- Description:	 
-- =============================================
CREATE procedure [dbo].[SP_MPY_PR_MM_AgregarFacturaPDF]
	-- Add the parameters for the stored procedure here
@IdProveedor int ,
@IdAceptacionPedido int,
@IdUsuario int  ,
@FacturaPDF IMAGE
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		
		DECLARE @IdFactura INT = (SELECT IdFactura
								  FROM MPY_MM_AceptacionFactura
								  WHERE IdAceptacionPedido = @IdAceptacionPedido)

		IF @IdFactura > 0

		BEGIN ---ACTUALIZAR PDF
			UPDATE FI_Factura 
			SET [ComprobantePDFByte]= @FacturaPDF,
			[ModificadoPor]= @IdUsuario,
			[ModificadoEn]=GETDATE()
			WHERE [IdFactura]= @IdFactura

			UPDATE MPY_MM_AceptacionFactura
			SET IdEstatusPDF = 1003,
			ModificadoPor= @IdUsuario,
			FechaCargaPDF = GETDATE()
			WHERE IdAceptacionPedido = @IdAceptacionPedido

		END 
		ELSE
		BEGIN ----NUEVO REGISTRO DE FACTURA

			INSERT INTO FI_Factura([ComprobantePDFByte])
			VALUES(@FacturaPDF)

			SET @IdFactura= (SELECT @@IDENTITY)

			UPDATE MPY_MM_AceptacionFactura
			SET IdFactura =@IdFactura,
			IdEstatusPDF =1003,
			[ModificadoPor]= @IdUsuario,
			FechaCargaPDF = GETDATE()
			WHERE [IdAceptacionPedido]= @IdAceptacionPedido

		END 
		 

		 SELECT 'Factura PDF Cargada Correctamente'
		
  END;


 

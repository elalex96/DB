-- =============================================
-- Author:		Alexander Gomez
-- Create date: 28/11/2018
-- Description:	Guardado del Registro SAP de factira
-- =============================================
CREATE procedure [dbo].[SP_MPY_FI_GuardarRegistroSAP] 
	@IdAceptacionFactura INT,
	@RegistroSAP BIT
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE dbo.MPY_MM_AceptacionFactura
	SET RegistroSAP = @RegistroSAP
	WHERE IdAceptacionPedido = @IdAceptacionFactura

END

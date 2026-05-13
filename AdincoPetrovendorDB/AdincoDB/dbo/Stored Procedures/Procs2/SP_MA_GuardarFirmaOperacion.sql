
-- =============================================
-- Author:		DANIEL AC
-- Create date: 29/01/2017
-- Description:	<Guarda la firma electronica por IdOperacion
-- =============================================

create procedure [dbo].[SP_MA_GuardarFirmaOperacion]

	@IdOperacion INT,
	@Firma NVARCHAR(35),	
    @IdContrato    INT = null,  
    @FechaRegistro DATETIME = null
 

AS
BEGIN
	UPDATE dbo.MA_Operacion
		SET IdFirma = @Firma
		WHERE IdOperacion = @IdOperacion
END



-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09/02/2018
-- Description:	Eliminar documento de declaracion fiscal
-- =============================================
CREATE PROCEDURE SP_CF_EliminarDeclaracionFiscal
    @IdDeclaracionFiscal INT
AS
BEGIN
	DELETE CF_DeclaracionFiscal WHERE IdDeclaracionFiscal = @IdDeclaracionFiscal
END

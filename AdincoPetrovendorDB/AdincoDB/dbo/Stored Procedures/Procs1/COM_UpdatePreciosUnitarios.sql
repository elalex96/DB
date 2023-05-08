-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180818
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE COM_UpdatePreciosUnitarios
   @idContrato INT,
    @idTipoHidrocarburo INT,
    @Mes DATE,
    @IdUsuario INT,
    @CostoUnitarioComercializacion FLOAT
AS
BEGIN
	
	SET NOCOUNT ON;

	 UPDATE dbo.COM_CostoUnitarioHidrocarburo
        SET CostoUnitarioComercializacion = @CostoUnitarioComercializacion,
		ModificadoPor=@IdUsuario,
		ModificadoEl=GETDATE()
        WHERE IdContrato = @idContrato
              AND IdTipoHidrocarburo = @idTipoHidrocarburo
              AND Mes = @Mes

END
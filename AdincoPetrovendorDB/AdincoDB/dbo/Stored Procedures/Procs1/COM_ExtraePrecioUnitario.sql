-- =============================================
-- Author:		Reyna Olvera
-- Create date:20180818
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE COM_ExtraePrecioUnitario
    -- Add the parameters for the stored procedure here
    @idContrato INT,
    @idTipoHidrocarburo INT,
    @Mes DATE,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT 
	CostoUnitarioComercializacion
    FROM COM_CostoUnitarioHidrocarburo
    WHERE IdContrato = @idContrato
          AND IdTipoHidrocarburo = @idTipoHidrocarburo
          AND MONTH(Mes) = Month(@Mes) AND year(Mes) = Year(@Mes);

END;
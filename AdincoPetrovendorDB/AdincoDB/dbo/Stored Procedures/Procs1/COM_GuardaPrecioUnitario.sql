-- =============================================
-- Author:		Reyna Olvera
-- Create date:20180818
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE COM_GuardaPrecioUnitario
    -- Add the parameters for the stored procedure here
    @idContrato INT,
    @idTipoHidrocarburo INT,
    @Mes DATE,
    @IdUsuario INT,
    @PrecioUnitario FLOAT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @Count INT;
    SELECT @Count = COUNT(CostoUnitarioComercializacion)
    FROM COM_CostoUnitarioHidrocarburo
    WHERE IdContrato = @idContrato
          AND IdTipoHidrocarburo = @idTipoHidrocarburo
          AND MONTH(Mes) = MONTH(@Mes)
          AND YEAR(Mes) = YEAR(@Mes);

    IF @Count <= 0
    BEGIN
        INSERT INTO dbo.COM_CostoUnitarioHidrocarburo
        (
            IdContrato,
            Mes,
            IdTipoHidrocarburo,
            CostoUnitarioComercializacion,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl
        )
        VALUES
        (   @idContrato,         -- IdContrato - int
            @Mes,                -- Mes - date
            @idTipoHidrocarburo, -- IdTipoHidrocarburo - int
            @PrecioUnitario,     -- CostoUnitarioComercializacion - money
            @IdUsuario,          -- CreadoPor - int
            GETDATE(),           -- CreadoEl - datetime
            NULL,                -- ModificadoPor - int
            NULL                 -- ModificadoEl - datetime
            );
    END;
    ELSE
    BEGIN
        UPDATE dbo.COM_CostoUnitarioHidrocarburo
        SET CostoUnitarioComercializacion = @PrecioUnitario,
		ModificadoPor=@IdUsuario,
		ModificadoEl=GETDATE()
        WHERE IdContrato = @idContrato
              AND IdTipoHidrocarburo = @idTipoHidrocarburo
              AND MONTH(Mes) = MONTH(@Mes)
              AND YEAR(Mes) = YEAR(@Mes);

    END;



END;